#!/bin/sh
# The fb sample is installed under /root/sample on kernel6 images and
# under /root/device_sample on kernel5 images. Use whichever is present.
for tool in /root/sample/ss928_fb_tool \
    /root/device_sample/ss928_fb_tool/ss928_fb_tool; do
    if [ -x "$tool" ]; then
        exec "$tool"
    fi
done

echo "ss928_fb_tool not found" >&2
exit 1