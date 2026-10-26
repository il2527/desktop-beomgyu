// Motion and step frames share one clock: no walking in place at path endpoints.
(() => {
 const $ = s => document.querySelector(s);
 const scene=$('.desktop-scene'), orbit=$('.orbit'), sprite=$('.sprite'), feet=$('.walking'), caption=$('.scene-caption');
 const hug=$('#hug-animation');
 const reduced=matchMedia('(prefers-reduced-motion: reduce)');
 let x=80,y=110,target=null,last=0,distance=0,speed=0,face=1,pauseUntil=0;
 document.body.classList.add('motion-ready');
 function reset(){target=null;speed=0;}
 document.querySelectorAll('input[name="size"]').forEach(el=>el.addEventListener('change',reset));
 const hugFrames = [{"delay":80,"src":"frame-000.png"},{"src":"frame-001.png","delay":80},{"src":"frame-002.png","delay":80},{"src":"frame-003.png","delay":80},{"src":"frame-004.png","delay":80},{"src":"frame-005.png","delay":80},{"delay":80,"src":"frame-006.png"},{"delay":80,"src":"frame-007.png"},{"src":"frame-008.png","delay":80},{"delay":80,"src":"frame-009.png"},{"src":"frame-010.png","delay":80},{"src":"frame-011.png","delay":80},{"delay":80,"src":"frame-012.png"},{"delay":80,"src":"frame-013.png"},{"delay":80,"src":"frame-014.png"},{"src":"frame-015.png","delay":80},{"delay":80,"src":"frame-016.png"},{"delay":80,"src":"frame-017.png"},{"src":"frame-018.png","delay":80},{"delay":80,"src":"frame-019.png"}];
 let hugTimer=null,hugIndex=0;
 const hugImages=hugFrames.map(frame=>{const img=new Image();img.src=frame.src;return img;});
 function hugStep(){
  if(!$('#hug').checked)return;
  hug.src=hugImages[hugIndex].src;
  const delay=hugFrames[hugIndex].delay;
  hugIndex=(hugIndex+1)%hugFrames.length;
  if(!reduced.matches)hugTimer=setTimeout(hugStep,delay);
 }
 function modeChanged(){
  reset();clearTimeout(hugTimer);hugIndex=0;
  if($('#hug').checked){hugStep();caption.textContent='A little hug, just for you ♡';}
  else caption.textContent=$('#celebrate').checked?'You did it! ✦':$('#stand').checked?'Keeping you company':'A little adventure';
 }
 document.querySelectorAll('input[name="movement"]').forEach(el=>el.addEventListener('change',modeChanged));
 reduced.addEventListener('change',modeChanged);
 function tick(now){
  const dt=Math.min((now-(last||now))/1000,.04);last=now;
  const maxX=Math.max(0,scene.clientWidth-orbit.clientWidth),maxY=Math.max(65,scene.clientHeight-orbit.clientHeight-55);
  x=Math.min(Math.max(x,0),maxX);y=Math.min(Math.max(y,65),maxY);
  const run=$('#run').checked,celebrate=$('#celebrate').checked,hugging=$('#hug').checked;
  const active=!$('#stand').checked&&!celebrate&&!hugging&&!reduced.matches;
  let moved=0;
  if(active&&now>pauseUntil){
   if(!target){
    target={x:Math.random()*maxX,y:65+Math.random()*Math.max(0,maxY-65)};
   }
   const dx=target.x-x,dy=target.y-y,len=Math.hypot(dx,dy);
   if(len<2){
    target=null;speed=0;pauseUntil=now+700+Math.random()*700;
   }else{
    speed=Math.min(speed+dt*180,run?95:42);moved=Math.min(len,speed*dt);x+=dx/len*moved;y+=dy/len*moved;
    if(Math.abs(dx)>.5)face=dx>0?1:-1;
    distance+=moved;
   }
  }else speed=0;
  const moving=moved>.01;document.body.classList.toggle('is-moving',moving);document.body.classList.toggle('running',run);
  if(moving){const frame=Math.floor(distance/(run?7:8))%6;if(run){$('.runner').src=`run-${frame%2}.png`;}feet.style.backgroundPosition=`${frame%3*50}% ${Math.floor(frame/3)*100}%`;}
  // The run photo faces left; the walk atlas faces right.
  const facing=moving&&run?-face:face;
  const bob=moving?Math.sin(distance*.19)*(run?2:1):celebrate?Math.sin(now*.006)*4:0;
  const drawX=hugging?maxX/2:x, drawY=hugging?maxY:y+bob;
  orbit.style.transform=`translate(${drawX}px,${drawY}px) scaleX(${moving?facing:1})`;
  requestAnimationFrame(tick);
 }
 requestAnimationFrame(tick);
})();
