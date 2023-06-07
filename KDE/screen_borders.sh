# Налаштування країв екрану для KDE

# Перевірка наявності файлу kwinrc
if [ ! -f "$HOME/.config/kwinrc" ]; then
    echo "Помилка: файл kwinrc не знайдено"
    exit 1
fi

# Check if [ElectricBorders] group exists before editing
if grep -q "\[ElectricBorders\]" ~/.config/kwinrc; then
    # Find the line number of the [ElectricBorders] group
    line=$(grep -n "\[ElectricBorders\]" ~/.config/kwinrc | cut -d ":" -f 1)

    # Find the line number of the next group
    next_line=$(tail -n +$((line+1)) ~/.config/kwinrc | grep -n "\[" | head -n 1 | cut -d ":" -f 1)
    if [ -z "$next_line" ]; then
        next_line=$(wc -l < ~/.config/kwinrc)
    else
        next_line=$((line+next_line-1))
    fi

    # Remove the [ElectricBorders] group and everything until the next group
    sed -i "$line,${next_line}d" ~/.config/kwinrc
    echo "Налаштування країв екрану: [ElectricBorders] успішно прибрано."
else
    echo "[ElectricBorders] не знайдено в файлі ~/.config/kwinrc. Немає потреби у змінах."
fi

# Check if [Effect-overview] group exists before editing
if grep -q "\[Effect-overview\]" ~/.config/kwinrc; then
    # Find the line number of the [Effect-overview] group
    line=$(grep -n "\[Effect-overview\]" ~/.config/kwinrc | cut -d ":" -f 1)

    # Find the line number of the next group
    next_line=$(tail -n +$((line+1)) ~/.config/kwinrc | grep -n "\[" | head -n 1 | cut -d ":" -f 1)
    if [ -z "$next_line" ]; then
        next_line=$(wc -l < ~/.config/kwinrc)
    else
        next_line=$((line+next_line-1))
    fi

    # Remove the [Effect-overview] group and everything until the next group
    sed -i "$line,${next_line}d" ~/.config/kwinrc
    echo "Налаштування країв екрану: [Effect-overview] успішно прибрано."
else
    echo "[Effect-overview] не знайдено в файлі ~/.config/kwinrc. Немає потреби у змінах."
fi
