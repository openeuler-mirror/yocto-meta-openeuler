(function() {
    if (!window.mermaid) {
        return;
    }

    let activeSvg = null;
    let panState = null;

    function initModal() {
        if (document.getElementById('mermaid-modal')) {
            return;
        }

        const modal = document.createElement('div');
        modal.id = 'mermaid-modal';
        modal.className = 'mermaid-modal';
        modal.innerHTML = '<span class="mermaid-close">&times;</span><div class="mermaid-modal-content"></div>';
        document.body.appendChild(modal);

        modal.querySelector('.mermaid-close').addEventListener('click', function(e) {
            e.stopPropagation();
            closeModal();
        });

        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                closeModal();
            }
        });

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeModal();
            }
        });

        document.addEventListener('mousemove', function(e) {
            if (!activeSvg || !panState || !panState.dragging) {
                return;
            }
            panState.x = e.clientX - panState.startX;
            panState.y = e.clientY - panState.startY;
            applyTransform(activeSvg);
        });

        document.addEventListener('mouseup', function() {
            if (panState) {
                panState.dragging = false;
            }
        });
    }

    function applyTransform(svg) {
        svg.style.transform = 'translate(' + panState.x + 'px, ' + panState.y + 'px) scale(' + panState.scale + ')';
    }

    function closeModal() {
        const modal = document.getElementById('mermaid-modal');
        if (!modal) {
            return;
        }

        modal.style.display = 'none';
        const content = modal.querySelector('.mermaid-modal-content');
        if (content) {
            content.innerHTML = '';
        }
        activeSvg = null;
        panState = null;
    }

    function openModal(svg) {
        const modal = document.getElementById('mermaid-modal');
        const content = modal ? modal.querySelector('.mermaid-modal-content') : null;
        if (!modal || !content) {
            return;
        }

        content.innerHTML = '';
        const clone = svg.cloneNode(true);
        clone.removeAttribute('width');
        clone.removeAttribute('height');
        clone.style.transformOrigin = 'center center';
        content.appendChild(clone);
        modal.style.display = 'flex';

        activeSvg = clone;
        panState = { scale: 1, x: 0, y: 0, dragging: false, startX: 0, startY: 0 };
        applyTransform(clone);

        clone.addEventListener('wheel', function(e) {
            e.preventDefault();
            const nextScale = panState.scale * (e.deltaY < 0 ? 1.1 : 0.9);
            panState.scale = Math.max(0.2, Math.min(8, nextScale));
            applyTransform(clone);
        });

        clone.addEventListener('mousedown', function(e) {
            panState.dragging = true;
            panState.startX = e.clientX - panState.x;
            panState.startY = e.clientY - panState.y;
        });
    }

    function bindMermaidZoom() {
        document.addEventListener('click', function(e) {
            const container = e.target.closest('.mermaid');
            if (!container) {
                return;
            }

            const svg = container.querySelector('svg');
            if (!svg) {
                return;
            }

            e.preventDefault();
            e.stopPropagation();
            openModal(svg);
        });
    }

    window.mermaid.initialize({
        startOnLoad: false,
        securityLevel: 'loose',
        theme: 'default'
    });

    window.addEventListener('load', function() {
        window.mermaid.run();
        initModal();
        bindMermaidZoom();
    });
})();
