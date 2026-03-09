#!/bin/bash

# Configuration
IMAGE_DIR="static/images"
MAX_WIDTH=1920
QUALITY=80
EXTENSIONS=("jpg" "jpeg" "png" "webp" "avif" "JPG" "JPEG" "PNG" "WEBP" "AVIF")

echo "----------------------------------------------------------------"
echo "Starting image optimization in: $IMAGE_DIR"
echo "Max width: ${MAX_WIDTH}px | Quality: $QUALITY%"
echo "----------------------------------------------------------------"
printf "%-50s | %-10s | %-10s | %s\n" "File" "Old (KB)" "New (KB)" "Saved"
echo "----------------------------------------------------------------"

for ext in "${EXTENSIONS[@]}"; do
    find "$IMAGE_DIR" -type f -name "*.$ext" | while read -r file; do
        # Get original size in KB
        OLD_SIZE=$(du -k "$file" | cut -f1)
        
        # Optimize based on extension in place
        case "$ext" in
            jpg|jpeg|JPG|JPEG)
                mogrify -resize "${MAX_WIDTH}x${MAX_WIDTH}>" -quality "$QUALITY" -interlace Plane "$file"
                ;;
            png|PNG)
                mogrify -resize "${MAX_WIDTH}x${MAX_WIDTH}>" -strip "$file"
                ;;
            webp|WEBP)
                mogrify -resize "${MAX_WIDTH}x${MAX_WIDTH}>" -quality "$QUALITY" "$file"
                ;;
            avif|AVIF)
                # Ensure existing AVIF is resized/compressed
                mogrify -resize "${MAX_WIDTH}x${MAX_WIDTH}>" -quality "$QUALITY" "$file"
                ;;
        esac

        # Get new size in KB
        NEW_SIZE=$(du -k "$file" | cut -f1)
        DIFF=$((OLD_SIZE - NEW_SIZE))

        # Output result for this file
        printf "%-50s | %-10d | %-10d | %d KB\n" "$(basename "$file")" "$OLD_SIZE" "$NEW_SIZE" "$DIFF"
    done
done

echo "----------------------------------------------------------------"
echo "Optimization complete."
