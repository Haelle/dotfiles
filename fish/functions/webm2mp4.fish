function webm2mp4 --description 'Convert a GNOME screencast (or any video) to a small WhatsApp-friendly mp4 (VAAPI hardware encode)'
    if test (count $argv) -eq 0
        echo "Usage: webm2mp4 file.webm [file2.webm ...]"
        return 1
    end

    set -l fps 30
    set -l width 1920
    set -l qp 20

    for f in $argv
        if not test -f $f
            echo "Not a file: $f"
            continue
        end
        set -l out (string replace -r '\.[^.]+$' '.mp4' -- $f)
        ffmpeg -y -vaapi_device /dev/dri/renderD128 \
            -i $f \
            -vf "fps=$fps,scale=$width:-2,format=nv12,hwupload" \
            -c:v h264_vaapi -qp $qp -movflags +faststart \
            -c:a aac -b:a 128k \
            $out
        and echo "✅ $out ("(du -h $out | cut -f1)")"
    end
end
