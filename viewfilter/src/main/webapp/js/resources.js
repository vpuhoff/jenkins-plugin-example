document.addEventListener('DOMContentLoaded', function () {
    // Выводим в консоль, чтобы знать что плагин загрузился.
    console.log('Custom JS loaded from resources.js!');
});

// Всратые снежинки
function createSnowflake() {
    const snowflake = document.createElement('div');
    snowflake.classList.add('snowflake');
    snowflake.innerHTML = '❆';
    
    // Set initial position
    snowflake.style.left = Math.random() * 100 + '%';
    
    // Faster, more consistent fall duration
    const duration = Math.random() * 1 + 2; // 2-3 seconds
    snowflake.style.animationDuration = duration + 's';
    
    // Visual properties
    snowflake.style.opacity = Math.random() * 0.7 + 0.3;
    snowflake.style.fontSize = Math.random() * 10 + 10 + 'px';
    
    // Add gentle sway
    const swayAmount = Math.random() * 30;
    snowflake.style.transform = `translateX(${Math.random() * swayAmount - swayAmount/2}px)`;
    
    document.querySelector('.snowflakes').appendChild(snowflake);
    
    // Remove after animation completes
    setTimeout(() => {
      snowflake.remove();
    }, duration * 1000);
  }
  
window.onload = function() {
    const snowflakesContainer = document.createElement('div');
    snowflakesContainer.classList.add('snowflakes');
    document.body.appendChild(snowflakesContainer);

    // Create snowflakes less frequently
    setInterval(createSnowflake, 300);
};

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
  
