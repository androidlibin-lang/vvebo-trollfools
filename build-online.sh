#!/bin/bash

# VVebo Fix 在线编译脚本
# 可以在 GitHub Codespaces 或其他在线环境中使用

echo "=== VVebo Fix 在线编译工具 ==="

# 检查是否在支持的环境中
if [[ "$CODESPACES" == "true" ]]; then
    echo "检测到 GitHub Codespaces 环境"
elif [[ -n "$GITPOD_WORKSPACE_ID" ]]; then
    echo "检测到 Gitpod 环境"
else
    echo "在通用 Linux 环境中运行"
fi

# 安装依赖
echo "安装构建依赖..."
sudo apt-get update
sudo apt-get install -y git make perl curl unzip build-essential

# 设置 Theos
echo "设置 Theos 环境..."
if [ ! -d "$HOME/theos" ]; then
    git clone --recursive https://github.com/theos/theos.git $HOME/theos
fi

export THEOS=$HOME/theos
export PATH=$THEOS/bin:$PATH

# 下载工具链
echo "下载 iOS 工具链..."
if [ ! -d "$THEOS/toolchain/linux/iphone" ]; then
    mkdir -p $THEOS/toolchain/linux/iphone
    curl -LO https://github.com/sbingner/llvm-project/releases/latest/download/linux-ios-arm64e-clang-toolchain.tar.lzma
    tar -xf linux-ios-arm64e-clang-toolchain.tar.lzma -C $THEOS/toolchain/linux/iphone --strip-components=1
    rm linux-ios-arm64e-clang-toolchain.tar.lzma
fi

# 下载 SDK
echo "下载 iOS SDK..."
if [ ! -d "$THEOS/sdks/iPhoneOS14.5.sdk" ]; then
    curl -LO https://github.com/theos/sdks/archive/master.zip
    unzip -q master.zip
    cp -r sdks-master/* $THEOS/sdks/
    rm -rf sdks-master master.zip
fi

# 构建项目
echo "开始构建 VVebo Fix..."
cd VVeboFix

# 清理之前的构建
make clean

# 编译并打包
make package FINALPACKAGE=1

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 构建成功！"
    echo "生成的 deb 文件："
    ls -la packages/*.deb
    echo ""
    echo "你可以下载这个 deb 文件并使用 TrollFools 注入到 VVebo 应用中。"
else
    echo "❌ 构建失败，请检查错误信息"
    exit 1
fi