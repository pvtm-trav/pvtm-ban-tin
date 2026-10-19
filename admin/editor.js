/* Small HTML-preserving editor using Decap's documented custom widget interface. */
(function(){
 var shell='<!doctype html><html lang="vi"><head><meta charset="utf-8"><style>body{padding:20px;font:14pt/1.4 "Times New Roman";color:#173f59}h1,h2{font-family:Arial;color:#003366}h1{font-size:16pt}img{max-width:90%;height:auto}table{border-collapse:collapse;width:100%}td,th{border:1px solid #ccd7e0;padding:6px}.credit{font-size:11pt}p{text-align:justify}</style></head><body contenteditable="true"></body></html>';
 var Control=createClass({
  getInitialState:function(){return {source:false};},
  attach:function(event){
   this.frame=event.target;var doc=this.frame.contentDocument;doc.body.innerHTML=this.props.value||'<p></p>';var self=this;
   doc.body.addEventListener('input',function(){self.props.onChange(doc.body.innerHTML);});
   doc.body.addEventListener('paste',function(e){e.preventDefault();doc.execCommand('insertText',false,(e.clipboardData||window.clipboardData).getData('text/plain'));});
  },
  command:function(name){if(this.frame){this.frame.contentWindow.focus();this.frame.contentDocument.execCommand(name,false,null);this.props.onChange(this.frame.contentDocument.body.innerHTML);}},
  render:function(){
   var self=this;var buttons=[['Đậm','bold'],['Nghiêng','italic'],['Gạch đầu dòng','insertUnorderedList']].map(function(v){return h('button',{key:v[1],type:'button',onClick:function(){self.command(v[1]);},style:{marginRight:'8px',padding:'7px'}},v[0]);});
   buttons.push(h('button',{key:'source',type:'button',onClick:function(){self.setState({source:!self.state.source});},style:{padding:'7px'}},this.state.source?'Soạn thảo':'Mã HTML'));
   return h('div',{className:this.props.classNameWrapper},h('div',{style:{marginBottom:'8px'}},buttons),this.state.source?h('textarea',{id:this.props.forID,value:this.props.value||'',onChange:function(e){self.props.onChange(e.target.value);},style:{width:'100%',minHeight:'500px',fontFamily:'monospace'}}):h('iframe',{title:'Soạn nội dung bài viết',srcDoc:shell,sandbox:'allow-same-origin',onLoad:this.attach,style:{width:'100%',height:'660px',border:'1px solid #ccd7e0',background:'white'}}));
  }
 });
 CMS.registerWidget('newsletter_html',Control);
})();
