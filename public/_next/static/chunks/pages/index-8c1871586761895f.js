(self.webpackChunk_N_E=self.webpackChunk_N_E||[]).push([[405],{8312:function(e,t,r){(window.__NEXT_P=window.__NEXT_P||[]).push(["/",function(){return r(4710)}])},4710:function(e,t,r){"use strict";r.r(t),r.d(t,{__N_SSG:function(){return D},default:function(){return I}});var a=r(5893),l=r(2984),s=r.n(l);r(4290);var n=r(7294);let c=(e,t)=>String(e).padStart(t,"0"),i=e=>"".concat(e.getFullYear()).concat(c(e.getMonth()+1,2)).concat(c(e.getDate(),2)),x=e=>{if(null===e)return"";let t=h(e);return"".concat(t.getMonth()+1,"月").concat(t.getDate(),"日(").concat(o(t.getDay()),")")},o=e=>["日","月","火","水","木","金","土"][e],h=e=>{let t=parseInt(e.substring(0,4)),r=parseInt(e.substring(4,6)),a=parseInt(e.substring(6,8));return new Date("".concat(t,"-").concat(c(r,2),"-").concat(c(a,2),"T00:00:00"))},d=(e,t)=>(e.getTime()-t.getTime())/1e3/60/60/24,u=e=>{let t="flex flex-column p-1 relative flex-1";return 0===e?t+" bg-amber-100 text-red-600":1===e?t+" text-red-600":2===e?t+" text-blue-600":t},f=e=>0===e?"今日":1===e?"明日":2===e?"明後日":"".concat(e,"日後");var m=e=>{let{today:t,garbage:r}=e,[l,s]=(0,n.useState)(null),[c,i]=(0,n.useState)(0);return(0,n.useEffect)(()=>{let e=r.garbageDates.filter(e=>e>=t);0!==e.length&&s(e[0])},[t,r]),(0,n.useEffect)(()=>{if(null===l)return;let e=h(t),r=h(l);i(d(r,e))},[l]),(0,a.jsxs)("div",{className:"flex flex-1 flex-row border border-gray-700 m-1 shadow-[5px_5px_5px_rgba(0,0,0,0.4)]",children:[(0,a.jsx)("div",{className:"text-white bg-main flex-1 text-sm p-1 relative before:content-[''] before:absolute before:inset-y-1/2 before:right-[-25px] before:mt-[-13px] before:border-[13px] before:border-transparent before:border-l-main z-10",children:(0,a.jsx)(n.Fragment,{children:r.garbageTitles.map((e,t)=>(0,a.jsx)("div",{children:e},t))})}),(0,a.jsxs)("div",{className:u(c),children:[(0,a.jsx)("div",{className:"flex flex-column flex-1 text-4xl text-center items-center justify-center",children:f(c)}),(0,a.jsx)("div",{className:"bottom-1 right-1 text-right absolute text-xs text-gray-600",children:x(l)})]})]})},g=e=>{let{today:t,area:r}=e;return(0,a.jsx)("div",{className:"grow grid grid-rows-4 auto-rows-fr",children:r.garbages.map((e,r)=>(0,a.jsx)(m,{today:t,garbage:e},r))})},b=r(5675),j=r.n(b),p=()=>(0,a.jsxs)("footer",{className:"flex justify-between m-1",children:[(0,a.jsx)("small",{className:"text-base",children:"\xa92023 webarata3（ARATA Shinichi）"}),(0,a.jsx)("a",{href:"https://twitter.com/webarata3",target:"_blank",className:"w-4",children:(0,a.jsx)(j(),{src:"/image/twitter.svg",width:16,height:16,alt:""})})]}),w=e=>{let{handleMenu:t}=e;return(0,a.jsxs)("header",{className:"flex flex-row flex-nowrap justify-start text-white bg-main text-2xl p-4",children:[(0,a.jsx)("button",{type:"button",className:"w-6 h-6 text-white",onClick:t,children:(0,a.jsx)("svg",{className:"w-6 h-6 text-white hover:text-sky-200",children:(0,a.jsx)("use",{xlinkHref:"image/bars.svg#bars"})})}),(0,a.jsx)("h1",{className:"text-xl flex-auto text-center",children:"白山市ゴミ収集日程"}),(0,a.jsx)("a",{href:"/",className:"w-6 h-6 text-white",children:(0,a.jsx)("svg",{className:"w-6 h-6 text-white hover:text-sky-s00",children:(0,a.jsx)("use",{xlinkHref:"image/rotate-right.svg#rotate-right"})})})]})},N=e=>{let{calendarUrl:t}=e;return(0,a.jsxs)("div",{className:"text-right px-1 w-full",children:[(0,a.jsx)("a",{href:"https://www.city.hakusan.lg.jp/seikatsu/kankyo/1001731/1005551/1007377.html",target:"_blank",rel:"noreferrer",className:"text-xs text-sky-600 mr-2",children:"地域が不明な方"}),(0,a.jsx)("a",{href:"https://gb.hn-kouiki.jp/hakusan",target:"_blank",rel:"noreferrer",className:"text-xs text-sky-600 mr-2",children:"ゴミ分別検索"}),(0,a.jsx)("a",{href:t,target:"_blank",rel:"noreferrer",className:"text-xs text-sky-600",children:"ゴミの出し方"})]})},v=e=>{let{regions:t,selectedAreaNo:r,handleOnChange:l}=e,s=(e,t)=>(0,a.jsx)("optgroup",{label:e.regionName,children:e.areas.map(e=>(0,a.jsx)("option",{value:e.areaNo,children:e.areaName},e.areaNo))},t);return(0,a.jsx)("div",{className:"items-center flex-1 flex-column text-sm py-2.5 px-5",children:(0,a.jsx)("div",{className:"flex flex-row items-center w-full",children:(0,a.jsx)("select",{className:"appearance-none border border-slate-400 flex-1 w-full p-2.5 bg-select bg-no-repeat bg-[99%_50%] bg-[length:18px_18px] bg-gray-100",id:"area",onChange:l,value:r,children:t.map((e,t)=>s(e,t))})})})},k=e=>{let{regions:t,selectedAreaNo:r,handleOnChange:l,calendarUrl:s}=e;return(0,a.jsxs)("section",{children:[(0,a.jsx)("div",{className:"mt-2.5 mb-0 mx-1 text-sm text-red-600 before:content-['※'] before:pr-0.5",children:"白山市公式のアプリではありません。"}),(0,a.jsx)(v,{regions:t,selectedAreaNo:r,handleOnChange:l}),(0,a.jsx)(N,{calendarUrl:s})]})},y=r(1664),_=r.n(y),S=e=>{let{openMenu:t,handleClose:r}=e;return(0,a.jsxs)(a.Fragment,{children:[(0,a.jsx)("div",{className:"fixed top-0 left-0 w-full h-full z-10 bg-black/[0.6] -translate-x-full ".concat(t?"translate-x-0":"-translate-x-full"),onClick:r}),(0,a.jsxs)("menu",{className:"fixed top-0 left-0 w-48 h-screen z-30 bg-white -translate-x-full transition-all ".concat(t?"translate-x-0":"-translate-x-full"),children:[(0,a.jsx)("div",{className:"flex justify-center relative p-4 bg-slate-300",children:(0,a.jsx)("button",{type:"button",onClick:r,children:(0,a.jsx)("svg",{className:"w-6 h-6 text-black hover:text-sky-800",children:(0,a.jsx)("use",{xlinkHref:"image/xmark.svg#xmark"})})})}),(0,a.jsxs)("ul",{className:"flex flex-col p-1 whitespace-nowrap",children:[(0,a.jsx)("li",{children:(0,a.jsxs)("a",{href:"how-to-use/",target:"_blank",className:"flex flex-row items-center gap-1 block text-black no-underline p-1 hover:bg-sky-100",children:[(0,a.jsx)("span",{children:"使い方"}),(0,a.jsx)("svg",{className:"w-4 h-4 text-black",children:(0,a.jsx)("use",{xlinkHref:"/image/open-right-square.svg#open-right-square"})})]})}),(0,a.jsx)("li",{className:"border-t border-solid border-slate-300",children:(0,a.jsx)(_(),{href:"/privacy/",className:"block text-black no-underline p-1 hover:bg-sky-100",children:"プライバシーポリシー"})}),(0,a.jsx)("li",{className:"border-t border-solid border-slate-300",children:(0,a.jsx)(_(),{href:"/disclaimer/",className:"block text-black no-underline p-1 hover:bg-sky-100",children:"免責事項"})}),(0,a.jsx)("li",{className:"border-t border-solid border-slate-300",children:(0,a.jsx)(_(),{href:"/credit/",className:"block text-black no-underline p-1 hover:bg-sky-100",children:"クレジット"})})]})]})]})},C=r(9008),E=r.n(C),D=!0,I=e=>{let{Component:t,pageProps:r,param:l}=e,[c,x]=(0,n.useState)(i(new Date)),[o,h]=(0,n.useState)("01"),[d,u]=(0,n.useState)(!1),f=l.areas.filter(e=>e.areaNo==o)[0];return(0,n.useEffect)(()=>{let e=setInterval(()=>{x(e=>{let t=i(new Date);return t!==e?t:e})},5e3);return()=>clearInterval(e)}),(0,n.useEffect)(()=>{var e;h(null!==(e=localStorage.getItem("areaNo"))&&void 0!==e?e:"01")},[]),(0,a.jsxs)(a.Fragment,{children:[(0,a.jsxs)(E(),{children:[(0,a.jsx)("meta",{name:"viewport",content:"viewport-fit=cover, width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"}),(0,a.jsx)("title",{children:"白山市ゴミ収集日程 - クリーン白山"}),(0,a.jsx)("link",{rel:"manifest",href:"/manifest.json"}),(0,a.jsx)("link",{rel:"apple-touch-icon",href:"/icon.png"}),(0,a.jsx)("meta",{name:"theme-color",content:"#428cee"})]}),(0,a.jsxs)("div",{className:"flex flex-col h-[100dvh] pb-iphone max-w-xl w-screen mx-auto box-border ".concat(s().className),children:[(0,a.jsx)(w,{handleMenu:()=>{u(!0)}}),(0,a.jsxs)("main",{className:"flex flex-col h-full w-full text-zinc-700 bg-white text-xl",children:[(0,a.jsx)(k,{regions:l.regions,selectedAreaNo:o,handleOnChange:e=>{h(e.target.value),localStorage.setItem("areaNo",e.target.value)},calendarUrl:f.calendarUrl}),(0,a.jsx)(g,{today:c,area:f})]}),(0,a.jsx)(p,{}),(0,a.jsx)(S,{openMenu:d,handleClose:()=>{u(!1)}})]})]})}},4290:function(){}},function(e){e.O(0,[381,774,888,179],function(){return e(e.s=8312)}),_N_E=e.O()}]);