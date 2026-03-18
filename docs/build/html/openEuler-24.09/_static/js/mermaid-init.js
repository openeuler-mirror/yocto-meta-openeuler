(function() {
    // 1. Initialize modal container as early as possible
    function initModal() {
        if (!document.getElementById('mermaid-modal')) {
            const modal = document.createElement('div');
            modal.id = 'mermaid-modal';
            modal.className = 'mermaid-modal';
            modal.style.display = 'none'; 
            modal.innerHTML = '<span class="mermaid-close">&times;</span><div class="mermaid-modal-content"></div>';
            document.body.appendChild(modal);

            const closeBtn = modal.querySelector('.mermaid-close');
            closeBtn.onclick = (e) => {
                e.stopPropagation();
                closeModal();
            };
            modal.onclick = (e) => {
                if (e.target === modal) closeModal();
            };
        }
    }

    let panzoomInstance = null;

    function closeModal() {
        const modal = document.getElementById('mermaid-modal');
        if (modal) {
            modal.style.display = 'none';
            if (panzoomInstance) {
                try {
                    if (typeof panzoomInstance.destroy === 'function') {
                        panzoomInstance.destroy();
                    }
                } catch(e) {
                    console.error("Error destroying panzoom:", e);
                }
                panzoomInstance = null;
            }
            // Clear content to free memory and prevent ghost clicks
            const modalContent = modal.querySelector('.mermaid-modal-content');
            if (modalContent) modalContent.innerHTML = '';
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initModal);
    } else {
        initModal();
    }

    // 2. Load Mermaid AND Panzoom
    function loadScript(src) {
        return new Promise((resolve, reject) => {
            if (document.querySelector(`script[src="${src}"]`)) {
                resolve();
                return;
            }
            const s = document.createElement('script');
            s.src = src;
            s.onload = resolve;
            s.onerror = reject;
            document.head.appendChild(s);
        });
    }

    Promise.all([
        loadScript('https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js'),
        loadScript('https://cdn.jsdelivr.net/npm/@panzoom/panzoom@4.5.1/dist/panzoom.min.js')
    ]).then(() => {
        
        // We MUST initialize mermaid since we disabled the default Sphinx module loader earlier
        mermaid.initialize({ 
            startOnLoad: true,
            securityLevel: 'loose',
            theme: 'default'
        });

        // Simple, robust click listener on the document
        document.addEventListener('click', function(e) {
            // Check if we clicked inside a mermaid container
            const container = e.target.closest('.mermaid');
            if (!container) return;

            const svg = container.querySelector('svg');
            if (!svg) return; 

            e.preventDefault();
            e.stopPropagation();

            const modal = document.getElementById('mermaid-modal');
            const modalContent = modal ? modal.querySelector('.mermaid-modal-content') : null;
            if (!modal || !modalContent) return;
            
            // Clean up any existing state
            closeModal();

            // Prepare new content
            const clonedSvg = svg.cloneNode(true);
            
            // Remove hardcoded dimensions to let CSS 100% and viewBox auto-fit it to the screen
            clonedSvg.removeAttribute('width');
            clonedSvg.removeAttribute('height');
            clonedSvg.removeAttribute('style'); // Clear any inline max-width etc.
            
            modalContent.appendChild(clonedSvg);
            modal.style.display = 'flex'; 

            // Initialize Panzoom on the newly appended SVG
            try {
                panzoomInstance = Panzoom(clonedSvg, {
                    maxScale: 30,
                    minScale: 0.1,
                    startScale: 1, // 1 means it fits exactly to the modal dimensions
                    contain: 'outside' // Prevents dragging the diagram completely out of view
                });

                // Set up mouse wheel zooming attached directly to the SVG
                clonedSvg.addEventListener('wheel', function(wheelEvent) {
                    wheelEvent.preventDefault();
                    if (panzoomInstance) {
                        panzoomInstance.zoomWithWheel(wheelEvent);
                    }
                });
            } catch (err) {
                console.error("Panzoom init failed:", err);
            }
        });
    }).catch(err => {
        console.error("Failed to load scripts", err);
    });
})();
