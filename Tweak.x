#import <Foundation/Foundation.h>

static NSString *storedUID = nil;

static NSString *extractUID(NSString *url) {
    if (!url) return nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"uid=(\\d+)" options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:url options:0 range:NSMakeRange(0, url.length)];
    if (!match) return nil;
    return [url substringWithRange:[match rangeAtIndex:1]];
}

static NSURLRequest *rewriteRequest(NSURLRequest *request) {
    NSString *urlString = request.URL.absoluteString;
    if (!urlString) return request;

    if ([urlString containsString:@"remind/unread_count"] || [urlString containsString:@"users/show"]) {
        NSString *uid = extractUID(urlString);
        if (uid.length) storedUID = uid;
        return request;
    }

    if (![urlString containsString:@"statuses/user_timeline"]) return request;

    NSString *uid = extractUID(urlString) ?: storedUID;
    if (!uid.length) return request;

    NSString *newURL = [urlString stringByReplacingOccurrencesOfString:@"statuses/user_timeline" withString:@"profile/statuses/tab"];
    newURL = [newURL stringByReplacingOccurrencesOfString:@"max_id" withString:@"since_id"];
    if (![newURL containsString:@"containerid="]) {
        newURL = [newURL stringByAppendingFormat:@"&containerid=230413%@_-_WEIBO_SECOND_PROFILE_WEIBO", uid];
    }

    NSMutableURLRequest *mutable = [request mutableCopy];
    mutable.URL = [NSURL URLWithString:newURL];
    return mutable;
}

static NSData *transformProfileData(NSData *originalData) {
    if (!originalData.length) return originalData;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:originalData options:0 error:nil];
    if (![jsonData isKindOfClass:[NSDictionary class]]) return originalData;

    NSArray *cards = jsonData[@"cards"];
    if (![cards isKindOfClass:[NSArray class]]) return originalData;

    NSMutableArray *statuses = [NSMutableArray array];
    for (id card in cards) {
        if (![card isKindOfClass:[NSDictionary class]]) continue;
        NSArray *group = card[@"card_group"];
        NSArray *items = [group isKindOfClass:[NSArray class]] ? group : @[card];
        for (id item in items) {
            if (![item isKindOfClass:[NSDictionary class]]) continue;
            if ([item[@"card_type"] intValue] != 9) continue;
            NSDictionary *mblog = item[@"mblog"];
            if (![mblog isKindOfClass:[NSDictionary class]]) continue;
            NSMutableDictionary *status = [mblog mutableCopy];
            if ([status[@"isTop"] boolValue] || [status[@"mblogtype"] intValue] == 1) {
                status[@"label"] = @"置顶";
            }
            [statuses addObject:status];
        }
    }

    id sinceId = jsonData[@"cardlistInfo"][@"since_id"] ?: @"";
    NSDictionary *out = @{
        @"statuses": statuses,
        @"since_id": sinceId,
        @"total_number": @100
    };
    return [NSJSONSerialization dataWithJSONObject:out options:0 error:nil] ?: originalData;
}

%hook NSURLSession

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    NSURLRequest *newReq = rewriteRequest(request);
    NSString *url = newReq.URL.absoluteString;
    if (completionHandler && [url containsString:@"profile/statuses/tab"]) {
        void (^wrapped)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
            completionHandler(transformProfileData(data), response, error);
        };
        return %orig(newReq, wrapped);
    }
    return %orig(newReq, completionHandler);
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request {
    return %orig(rewriteRequest(request));
}

%end

%ctor {
    NSLog(@"[VVeboFix] loaded");
}
