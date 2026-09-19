document.addEventListener('DOMContentLoaded', function() {
    // 1. Process "Source" blocks (paragraphs starting with 来源, 源文件, 关键文件, etc.)
    const paragraphs = document.querySelectorAll('p');
    paragraphs.forEach(p => {
        const html = p.innerHTML.trim();
        // Regex to match "来源", "源文件", "关键文件", "关键函数" possibly inside <strong> and followed by colon
        const sourceRegex = /^(<strong>)?(来源|源文件|关键文件|关键函数)(<\/strong>)?[:：]/;
        
        if (sourceRegex.test(html)) {
            p.classList.add('source-block');
            
            // Standardize the prefix to include the icon and remove the colon
            p.innerHTML = html.replace(sourceRegex, (match, p1, label, p2) => {
                return `<strong><i class="fa fa-book"></i> ${label}</strong>`;
            });
        }
    });

    // 2. Globally find all file links and turn them into badges
    const links = document.querySelectorAll('a.reference.external');
    links.forEach(link => {
        let text = link.textContent.trim();
        
        // Clean up text (remove spaces introduced by Sphinx layout)
        const cleanedText = text.replace(/\s/g, '');
        
        // Pattern for badge: something.ext:123 or something.ext
        // Group 1: filename, Group 2: lines/function (optional)
        const match = cleanedText.match(/^([^:\s]+)(?::([^:\s]+))?$/);
        
        // We only want to badge links that look like source paths (contain . or /)
        // and aren't full URLs (which a.reference.external might be, but textContent would be different)
        if (match && (cleanedText.includes('.') || cleanedText.includes('/'))) {
            const filename = match[1];
            const suffix = match[2];
            
            if (suffix) {
                link.innerHTML = `<span class="src-file">${filename}</span><span class="src-lines">${suffix}</span>`;
                link.classList.add('source-link-split');
            } else {
                // Just a file link, use a single badge style
                link.innerHTML = `<span class="src-file-only">${filename}</span>`;
                link.classList.add('source-link-single');
            }
            
            if (!link.closest('.source-block')) {
                link.classList.add('inline-source-badge');
            }
        }
    });
});
