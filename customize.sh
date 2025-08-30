SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=true
LATESTARTSERVICE=true
REPLACE=""

# 模块信息
id=Flyme_GT
name="电池信息展示&优化温控限制"
version=V1.0.0
versionCode=1
author=Hoerire
description="Flyme_GT"

# 生成module.prop
echo "id=$id
name=$name
version=$version
versionCode=$versionCode
author=$author
description=$description" > $MODPATH/module.prop

# 安装提示
ui_print "模块: $name"
ui_print "版本: $version"
ui_print "安装完成"
ui_print "点击小三角执行刷新电池信息"
