document.addEventListener('DOMContentLoaded', function () {
    // Выводим в консоль, чтобы знать что плагин загрузился.
    console.log('Custom JS loaded from resources.js!');
});

/* Летающий кот */

window.onload = function() {
    const cat = document.createElement('div');
    cat.className = 'cat';
    
    cat.innerHTML = `
      <div class="cat-body"></div>
      <div class="cat-head">
        <div class="cat-ear left"></div>
        <div class="cat-ear right"></div>
        <div class="cat-eye left"></div>
        <div class="cat-eye right"></div>
      </div>
      <div class="cat-tail"></div>
    `;
    
    document.body.appendChild(cat);
    
    let currentX = 0;
    let currentY = 0;
    let targetX = 0;
    let targetY = 0;
    
    document.addEventListener('mousemove', (e) => {
      targetX = e.clientX - 25;
      targetY = e.clientY - 25;
    });
    
    function animate() {
      // Smooth movement
      currentX += (targetX - currentX) * 0.1;
      currentY += (targetY - currentY) * 0.1;
      
      // Calculate direction for cat facing
      const angle = Math.atan2(targetY - currentY, targetX - currentX);
      const rotation = angle * (180 / Math.PI);
      
      cat.style.transform = `translate(${currentX}px, ${currentY}px) rotate(${rotation}deg)`;
      
      requestAnimationFrame(animate);
    }
    
    animate();
  };
  
