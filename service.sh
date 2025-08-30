#!/system/bin/sh
MODDIR=$(dirname "$(readlink -f "$0")")
MODULE_PROP="$MODDIR/module.prop" 

# 核心函数：读取电池信息并更新 module.prop
update_battery_info() {
    # 动态定位电池目录（优先常见路径）
    battery_paths="/sys/class/power_supply/battery /sys/class/power_supply/bat0"
    battery=""
    for path in $battery_paths; do
        if [ -d "$path" ]; then
            battery="$path"
            break
        fi
    done
    # 未找到时全局搜索备用
    [ -z "$battery" ] && battery=$(find /sys/class/power_supply/ -type d -iname "*batt*" 2>/dev/null | head -n 1)

    # 设计容量（转换为 mAh）
    cfd=$(cat "${battery}/charge_full_design" 2>/dev/null || echo 0)
    charge_full_design=$((cfd / 1000))
    [ $charge_full_design -eq 0 ] && charge_full_design="未知"

    # 当前满电容量（转换为 mAh）
    cf=$(cat "${battery}/charge_full" 2>/dev/null || echo 0)
    charge_full=$((cf / 1000))
    [ $charge_full -eq 0 ] && charge_full="未知"

    # 循环次数
    cc=$(cat "${battery}/cycle_count" 2>/dev/null || echo "未知")

    # 计算健康度（百分比）
    bfb="未知"
    [ "$cfd" -ne 0 ] && [ "$cf" -ne 0 ] && bfb=$((cf * 100 / cfd))

    # 电池温度（整数℃）
    temp=$(cat "${battery}/temp" 2>/dev/null)
    battery_temp="未知"
    [ -n "$temp" ] && [ "$temp" -ne 0 ] && battery_temp="$((temp / 10))℃"

    # 读取充电状态
    charge_status="未知"
    status=$(cat "${battery}/status" 2>/dev/null)
    case "$status" in
        "Charging") charge_status="充电中" ;;
        "Full") charge_status="已充满" ;;
        "Discharging") charge_status="未充电" ;;
        "Not charging") charge_status="未充电" ;;
        "Fast charging") charge_status="快充中" ;;
        *) charge_status="$status" ;;
    esac

    # 读取当前电量（百分比）
    current_capacity="未知"
    capacity=$(cat "${battery}/capacity" 2>/dev/null)
    [ -n "$capacity" ] && [ "$capacity" -ge 0 ] && [ "$capacity" -le 100 ] && current_capacity="${capacity}%"

    # 获取当前刷新时间（格式：年-月-日 时:分:秒）
    refresh_time=$(date +%Y-%m-%d\ %H:%M:%S)

    # 整合信息
    devices="设计容量:${charge_full_design}mAh  当前容量:${charge_full}mAh  循环次数:${cc}次  健康度:${bfb}%  电池温度:${battery_temp}  充电状态:${charge_status}  当前电量:${current_capacity}  更新时间:${refresh_time}"

    # 更新 module.prop
    if [ -w "$MODULE_PROP" ]; then
        sed -i '/^description=/d' "$MODULE_PROP" 2>/dev/null
        echo "description=${devices}" >> "$MODULE_PROP"
    fi
}

# 调用函数执行更新
update_battery_info



