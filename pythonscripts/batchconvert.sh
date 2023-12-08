for file in original/*.png; do
    convert "$file" -resize 50% "compressed/$(basename "$file")"
done
