// Photo-textured arm strips share vertices at each joint. The shoulder root stays
// attached to the torso; there are no independently rotating sleeve cutouts.
(() => {
 const NS='http://www.w3.org/2000/svg';
 const el=(name,attrs={})=>{const e=document.createElementNS(NS,name);for(const [k,v]of Object.entries(attrs))e.setAttribute(k,v);return e;};
 function rings(points,widths){
  return points.map((p,i)=>{
   const a=points[Math.max(0,i-1)],b=points[Math.min(points.length-1,i+1)];
   const dx=b[0]-a[0],dy=b[1]-a[1],len=Math.hypot(dx,dy);
   return [[p[0]-dy/len*widths[i],p[1]+dx/len*widths[i]],[p[0]+dy/len*widths[i],p[1]-dx/len*widths[i]]];
  });
 }
 function affine(s,d){
  const [a,b,c]=s,[u,v,w]=d;
  const det=(b[0]-a[0])*(c[1]-a[1])-(c[0]-a[0])*(b[1]-a[1]);
  const A=((v[0]-u[0])*(c[1]-a[1])-(w[0]-u[0])*(b[1]-a[1]))/det;
  const C=((w[0]-u[0])*(b[0]-a[0])-(v[0]-u[0])*(c[0]-a[0]))/det;
  const B=((v[1]-u[1])*(c[1]-a[1])-(w[1]-u[1])*(b[1]-a[1]))/det;
  const D=((w[1]-u[1])*(b[0]-a[0])-(v[1]-u[1])*(c[0]-a[0]))/det;
  return `matrix(${A} ${B} ${C} ${D} ${u[0]-A*a[0]-C*a[1]} ${u[1]-B*a[0]-D*a[1]})`;
 }
 const rotate=(p,o,r)=>[o[0]+(p[0]-o[0])*Math.cos(r)-(p[1]-o[1])*Math.sin(r),o[1]+(p[0]-o[0])*Math.sin(r)+(p[1]-o[1])*Math.cos(r)];
 const specs={
  walk:[
   {name:'front-arm',points:[[270,155],[305,235],[355,285],[371,301]],widths:[23,20,15,23],swing:46,lower:40,elbow:1},
   {name:'rear-arm',points:[[215,155],[180,250],[155,330],[155,351]],widths:[25,22,15,21],swing:-46,lower:-40,elbow:1}
  ],
  run:[
   {name:'front-arm',points:[[460,330],[330,460],[210,335],[195,305]],widths:[65,38,28,43],swing:-88,lower:-154,elbow:1},
   {name:'back-arm',points:[[690,330],[815,360],[910,445],[960,530],[985,555]],widths:[70,58,36,29,36],swing:97,lower:169,elbow:2}
  ]
 };
 const rigs={};
 function init(gait,svg){
  const defs=svg.querySelector('defs');
  svg.querySelectorAll(`.${gait}-socket`).forEach(e=>e.remove());
  rigs[gait]=specs[gait].map((spec,arm)=>{
   const group=svg.querySelector('.'+gait+'-'+spec.name);group.replaceChildren();group.removeAttribute('transform');
   const src=rings(spec.points,spec.widths),triangles=[];
   for(let row=0;row<src.length-1;row++)for(const indices of [[[row,0],[row,1],[row+1,0]],[[row,1],[row+1,1],[row+1,0]]]){
    const pts=indices.map(([r,c])=>src[r][c]);
    const id=`${gait}-arm-mesh-${arm}-${triangles.length}`;
    const clip=el('clipPath',{id,clipPathUnits:'userSpaceOnUse'});
    // A tiny texture overlap avoids antialias cracks between shared triangles.
    const center=[pts.reduce((a,p)=>a+p[0],0)/3,pts.reduce((a,p)=>a+p[1],0)/3];
    clip.append(el('polygon',{points:pts.map(p=>p.map((n,i)=>center[i]+(n-center[i])*1.006).join(',')).join(' ')}));defs.append(clip);
    const patch=el('g');patch.append(el('use',{href:'#'+gait+'-photo','clip-path':`url(#${id})`}));group.append(patch);
    triangles.push({indices,pts,patch});
   }
   return {spec,src,triangles,group};
  });
 }
 function update(gait,phase){
  const exchange=(1-Math.cos(phase))/2;
  for(const {spec,src,triangles}of rigs[gait]){
   const amount=1-exchange,root=spec.points[0],joint=spec.points[spec.elbow];
   const upper=spec.swing*amount*Math.PI/180,lower=spec.lower*amount*Math.PI/180;
   const movedJoint=rotate(joint,root,upper);
   const destPoints=spec.points.map((p,i)=>{
    if(i<=spec.elbow)return rotate(p,root,upper);
    const q=rotate(p,joint,lower);
    return [q[0]+movedJoint[0]-joint[0],q[1]+movedJoint[1]-joint[1]];
   });
   const dest=rings(destPoints,spec.widths);
   // The torso attachment edge is invariant at every phase.
   dest[0]=src[0];
   for(const {indices,pts,patch}of triangles)patch.setAttribute('transform',affine(pts,indices.map(([r,c])=>dest[r][c])));
  }
 }
 window.PhotoGaits={init,update};
})();
