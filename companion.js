// Motion and step frames share one clock: no walking in place at path endpoints.
(() => {
 const $ = s => document.querySelector(s);
 const scene=$('.desktop-scene'), orbit=$('.orbit'), sprite=$('.sprite'), feet=$('.walking'), caption=$('.scene-caption');
 const hug=$('#hug-animation');
 const runParts=['front-leg','back-leg'].map(name=>$('.run-'+name));
 const walkParts=['front-leg','rear-leg'].map(name=>$('.walk-'+name));
 PhotoGaits.init('walk',$('.walk-rig'));
 PhotoGaits.init('run',$('.run-rig'));
 const reduced=matchMedia('(prefers-reduced-motion: reduce)');
 let x=80,y=110,target=null,last=0,distance=0,speed=0,face=1,heading=.4,turn=0,turnAt=0;
 document.body.classList.add('motion-ready');
 function reset(){target=null;speed=0;turnAt=0;}
 document.querySelectorAll('input[name="size"]').forEach(el=>el.addEventListener('change',reset));
 const hugFrames = [{"delay":80,"src":"frame-000.png"},{"src":"frame-001.png","delay":80},{"src":"frame-002.png","delay":80},{"src":"frame-003.png","delay":80},{"src":"frame-004.png","delay":80},{"src":"frame-005.png","delay":80},{"delay":80,"src":"frame-006.png"},{"delay":80,"src":"frame-007.png"},{"src":"frame-008.png","delay":80},{"delay":80,"src":"frame-009.png"},{"src":"frame-010.png","delay":80},{"src":"frame-011.png","delay":80},{"delay":80,"src":"frame-012.png"},{"delay":80,"src":"frame-013.png"},{"delay":80,"src":"frame-014.png"},{"src":"frame-015.png","delay":80},{"delay":80,"src":"frame-016.png"},{"delay":80,"src":"frame-017.png"},{"src":"frame-018.png","delay":80},{"delay":80,"src":"frame-019.png"}];
 let hugTimer=null,hugIndex=0;
 const hugImages=hugFrames.map(frame=>{const img=new Image();img.src=frame.src;return img;});
 function hugStep(){
  if(!$('#hug').checked)return;
  hug.src=hugImages[hugIndex].src;
  const delay=hugFrames[hugIndex].delay * ($("#quiet").checked ? 1.7 : 1);
  hugIndex=(hugIndex+1)%hugFrames.length;
  if(!reduced.matches)hugTimer=setTimeout(hugStep,delay);
 }
 function updatePace(){
  const value=Number($('#pace').value);
  $('#pace-value').textContent=value+'%';
  $('#pace').setAttribute('aria-valuetext',value+' percent of usual walking or running speed');
 }
 $('#pace').addEventListener('input',updatePace);
 function modeChanged(){
  updatePace();
  reset();clearTimeout(hugTimer);hugIndex=0;
  const quiet=$('#quiet').checked;
  document.body.classList.toggle('quiet-comfort',quiet);
  const mode=document.querySelector('input[name="movement"]:checked').id;
  const descriptions={
   stand: quiet?'He stays nearby, quietly keeping you company.':'He stays nearby. Choose Walk or Run to see him move.',
   walk: quiet?'He takes a slow, gentle walk.':'He keeps wandering with gentle, unpredictable turns.',
   run: quiet?'He jogs at an easier pace, without rushing.':'He runs around the preview with quicker steps.',
   celebrate: quiet?'A small, gentle celebration. Your little wins count.':'A happy bounce to celebrate your little wins!',
   hug: quiet?'A slower hug. Take your time; there is no need to rush.':'An animated hug, just for you. You can always switch back to Stay.'
  };
  $('#response-title').textContent=({stand:'Stay',walk:'Walk',run:'Run',celebrate:'Celebrate',hug:'Hug'})[mode]+' · '+(quiet?'Quiet comfort':'Playful');
  $('#response-description').textContent=descriptions[mode];
  if($('#hug').checked)hugStep();
  caption.textContent=descriptions[mode];
 }
 document.querySelectorAll('input[name="movement"]').forEach(el=>el.addEventListener('change',modeChanged));
 $('#quiet').addEventListener('change',modeChanged);
 document.querySelector('form').addEventListener('reset',()=>setTimeout(modeChanged,0));
 reduced.addEventListener('change',modeChanged);
 modeChanged();
 // Anatomical depth is fixed: swinging a limb does not change which side
 // of the body it belongs to. Mirroring the whole character preserves this.
 for(const gait of ['walk','run']){
  const body=$('.'+gait+'-body'),head=$('.'+gait+'-head'),parent=body.parentNode;
  // Running depth is reversed as requested; walking keeps its existing order.
  const near=$('.'+gait+(gait==='walk'?'-rear-arm':'-back-arm'));
  const far=$('.'+gait+(gait==='walk'?'-front-arm':'-front-arm'));
  parent.insertBefore(far,parent.firstElementChild);
  parent.appendChild(near);
  parent.appendChild(head);
 }
 function tick(now){
  const dt=Math.min((now-(last||now))/1000,.04);last=now;
  const minX=32,minY=12;
  const maxX=Math.max(minX,scene.clientWidth-orbit.clientWidth-32),maxY=Math.max(minY,scene.clientHeight-orbit.clientHeight-88);
  x=Math.min(Math.max(x,minX),maxX);y=Math.min(Math.max(y,minY),maxY);
  const run=$('#run').checked,celebrate=$('#celebrate').checked,hugging=$('#hug').checked;
  const active=!$('#stand').checked&&!celebrate&&!hugging&&!reduced.matches;
  let moved=0;
  if(active){
   // Continuous correlated wandering: random gentle turns, no target stops or loops.
   if(now>turnAt){turn=(Math.random()-.5)*1.5;turnAt=now+700+Math.random()*1600;}
   heading+=turn*dt;
   let vx=Math.cos(heading),vy=Math.sin(heading);
   const edge=55;
   vx+=Math.max(0,1-(x-minX)/edge)*2-Math.max(0,1-(maxX-x)/edge)*2;
   vy+=Math.max(0,1-(y-minY)/edge)*2-Math.max(0,1-(maxY-y)/edge)*2;
   const desired=Math.atan2(vy,vx);
   const delta=Math.atan2(Math.sin(desired-heading),Math.cos(desired-heading));
   heading+=delta*Math.min(1,dt*4);
   speed=Math.min(speed+dt*180,(run?110:48)*(Number($('#pace').value)/100)*($('#quiet').checked?.55:1));
   const nx=Math.min(maxX,Math.max(minX,x+Math.cos(heading)*speed*dt));
   const ny=Math.min(maxY,Math.max(minY,y+Math.sin(heading)*speed*dt));
   moved=Math.hypot(nx-x,ny-y);
   if(Math.abs(nx-x)>.02)face=nx>x?1:-1;
   x=nx;y=ny;distance+=moved;
  }else speed=0;
  const moving=moved>.01;document.body.classList.toggle('is-moving',moving);document.body.classList.toggle('running',run);
  if(moving&&!run){
   const exchange=(1-Math.cos(distance/38*Math.PI*2))/2;
   const poses=[[48*exchange,245,280],[-48*exchange,230,280]];
   // Opposite arm and leg advance together: arms are half a stride ahead.
   PhotoGaits.update('walk',distance/38*Math.PI*2+Math.PI);
   walkParts.forEach((part,i)=>part.setAttribute('transform',`rotate(${poses[i].join(' ')})`));
  }
  // One full stride per 46 pixels. Opposite arms follow opposite legs.
  // These transforms move clipped original photo pixels, including an untouched head.
  if(run&&moving){
   const exchange=(1-Math.cos(distance/46*Math.PI*2))/2;
   const poses=[[-65*exchange,590,700],[90*exchange,650,740]];
   PhotoGaits.update('run',distance/46*Math.PI*2+Math.PI);
   runParts.forEach((part,i)=>part.setAttribute('transform',`rotate(${poses[i].join(' ')})`));
  }
  // The run photo faces left; the walk atlas faces right.
  const facing=moving&&run?-face:face;
  const bob=moving?Math.sin(distance*.19)*(run?2:1):celebrate?Math.sin(now*.006)*($('#quiet').checked?1:4):0;
  const drawX=hugging?maxX/2:x, drawY=hugging?maxY:y+bob;
  orbit.style.transform=`translate(${drawX}px,${drawY}px) scaleX(${moving?facing:1})`;
  requestAnimationFrame(tick);
 }
 requestAnimationFrame(tick);
})();
