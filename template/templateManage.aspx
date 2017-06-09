﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="templateManage.aspx.cs" Inherits="template.templateAdmin" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>模板管理</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/react/15.0.2/react.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/react/15.0.2/react-dom.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/babel-core/5.8.23/browser.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.0/jquery.min.js"></script>
    <script src="http://code.jquery.com/ui/1.10.2/jquery-ui.js"></script>
    <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" />
    <script src="assets/jquery.multiple.select.js"></script>
    <link href="assets/multiple-select.css" rel="stylesheet" />
    <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
    <link href="assets/templateManage.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
    </form>
    
        <div class='container'>
        <div class='row' >
            <div id='root' class='col-xs-12'>
            </div>
        </div>
    </div>
    <div id='dialogDiv'></div>

<script type="text/babel">
var Root=React.createClass({
    getInitialState: function() {
        return {data: [],loadTemplate:{}};
    },
    componentWillMount: function() {
        $.ajax({
            url: "templateManage.asmx/getTemplateXml",
            async: false,
            type: 'POST',
            data: '',
            datatype: 'xml',
            success: function(data) {
                    if(data.getElementsByTagName('error').length!=0){
                   alert(data.getElementsByTagName('error')[0].innerHTML);
                    return;
                }
                this.setState({data: data});
                if(data.getElementsByTagName('error').length!=0){
                   alert(data.getElementsByTagName('error')[0].innerHTML);
                    return;
                }
            }.bind(this),
            error: function(xhr, status, err) {
                console.error(this.props.url, status, err.toString());
            }.bind(this)
        });
    },
    loadTemplate:function(data,xPath,mode){
        if(data==null){
            //修改xParh
            var loadTemplate=this.state.loadTemplate;
            loadTemplate.xPath=xPath;    
        }
        else{
            //新資料s
            var loadTemplate={data:data,xPath:xPath};    
        }
        if(mode=='edit'){
            this.setState({loadTemplate:loadTemplate},this.refs.TemplatePanel.enterEditMode);    
        }
        else{
            this.setState({loadTemplate:loadTemplate});
        }

        
    },
    renewData:function(data,newXPath,makeTemp){
        this.setState({data:data},function(){
            if(makeTemp==true){
                this.state.loadTemplate.xPath=newXPath;
            }
            if(this.state.loadTemplate.xPath!=undefined){
                //原本有預覽的模板
                var node = document.evaluate(this.state.loadTemplate.xPath, this.state.data, null, XPathResult.ANY_TYPE, null).iterateNext();
                if(node!=null){
                    //是否進入新節點
                    if(newXPath!=undefined){
                        var newNode = document.evaluate(newXPath, data, null, XPathResult.ANY_TYPE, null).iterateNext();
                        if(newNode!=null){
                            if(makeTemp==true){
                                this.loadTemplate(newNode,newXPath,'edit');
                            }
                            else{
                                this.loadTemplate(newNode,newXPath);
                            }
                        }
                        else{
                            this.loadTemplate(undefined,undefined);
                        }
                    }
                    else{
                        this.loadTemplate(node,this.state.loadTemplate.xPath);
                    }
                }
                else{
                    //節點已死亡
                    alert('無法連結預覽模板資料');
                    this.loadTemplate(undefined,undefined);
                }
            }
            else{
                //無預覽模板
            }
        });
    },
    render:function(){
        return(
            <div className='row'>
            <div className='col-xs-12'>
            <div className='row'>
            <div className='col-xs-12'>
            <Menu data={this.state.data.getElementsByTagName('root')[0]} renewData={this.renewData}/>
            </div>
            </div>
            <div className='row'>
            <div className='col-xs-3'>
            <DirList id='directoryMenu' className="boundBlock" data={this.state.data.getElementsByTagName('root')[0]} loadTemplate={this.loadTemplate} />
            </div>
            <div className='col-xs-9'>
            <TemplatePanel ref='TemplatePanel' data={this.state.loadTemplate?this.state.loadTemplate.data:undefined} xPath={this.state.loadTemplate?this.state.loadTemplate.xPath:undefined} renewData={this.renewData} setNewXPath={this.loadTemplate.bind(null,null)}/>
            </div>
            </div>
            </div>
            </div>
            );
    }
});
var Menu=React.createClass({
    newDirMenuDialog:function(toDo){
        ReactDOM.render(
            <DirMenuDialog data={this.props.data} toDo={toDo} renewData={this.props.renewData}/>,
            document.getElementById('dialogDiv')
            );
    },
    render:function(){
        return(
        <div id="menuBar" className='boundBlock'>
        <div id="menuBarButtons" className='txtRight'>
        <button type="button" className="btn btn-primary" onClick={this.newDirMenuDialog.bind(null,'makeDir')}>新增資料夾</button>
        <button type="button" className="btn btn-primary" onClick={this.newDirMenuDialog.bind(null,'makeTemp')}>新增模版</button>
        <button type="button" className="btn btn-primary" onClick={this.newDirMenuDialog.bind(null,'rename')}>重新命名</button>
        <button type="button" className="btn btn-primary" onClick={this.newDirMenuDialog.bind(null,'moveTo')}>移動至</button>
        <button type="button" className="btn btn-primary" onClick={this.newDirMenuDialog.bind(null,'delete')}>刪除</button>
        </div>
        </div>
        );
    }
});
var DirMenuDialog=React.createClass({
    toSelect:function(from,selectedItem){

        if(this.state.selectedItem[from]!=undefined)
            this.state.selectedItem[from].setStateFromOutside({selected:false});
        selectedItem.setStateFromOutside({selected:true});
        this.state.selectedItem[from]=selectedItem;
        this.setState({selectedItem:this.state.selectedItem});
    },
    toSelectParent:function(from,selectedItem){

        if(this.state.selectedItem[from]!=undefined)
            this.state.selectedItem[from].props.parent.setStateFromOutside({selected:false});
        selectedItem.props.parent.setStateFromOutside({selected:true});
        this.state.selectedItem[from]=selectedItem;
        this.setState({selectedItem:this.state.selectedItem});
    },
    componentDidMount:function(){
        $("#dialog").dialog({
            autoOpen: false,
            width: 700,
            modal: true,
            buttons: {
                '確定': function () {
                    switch(this.props.toDo){
                        case 'delete':
                        if(this.state.selectedItem[0]==null){
                            alert('不可有欄位為空');
                            return ;
                        }
                        var data={argv0:this.state.selectedItem[0].props.parent.makeXPath()};
                        break;
                        case 'moveTo':
                        if(this.state.selectedItem[0]==null||this.state.selectedItem[1]==null){
                            alert('不可有欄位為空');
                            return ;
                        }

                        var data={argv0:this.state.selectedItem[0].props.parent.makeXPath(),argv1:this.state.selectedItem[1].props.parent.makeXPath(),true};
                        break;
                        default:
                        if(this.state.selectedItem[0]==null||this.refs.input.value==''){
                            alert('不可有欄位為空');
                            return
                        }
                        var data={argv0:this.state.selectedItem[0].props.parent.makeXPath(),argv1:this.refs.input.value};

                        break;
                    }
                    $.ajax({
                        url: "templateManage.asmx/"+this.props.toDo,
                        async: false,
                        type: 'POST',
                        data:data,
                        datatype: 'xml',
                        success: function (result) {
                    if(result.getElementsByTagName('error').length!=0){
                   alert(result.getElementsByTagName('error')[0].innerHTML);
                    return;
                }
                            if(this.props.toDo=='makeTemp'){
                                this.props.renewData(result,this.state.selectedItem[0].props.parent.makeXPath()+'/template[@name="'+this.refs.input.value+'"]',true);
                            }
                            else{
                                this.props.renewData(result,undefined);
                            }
                        }.bind(this),
                        error: function (xhr, status, error) {
                            alert(error);
                        }
                    });

                    $('#dialog').dialog("close");
                    $("#dialog").remove();
                    ReactDOM.unmountComponentAtNode(document.getElementById('dialogDiv'));

                }.bind(this),
                '取消': function(){
                    $('#dialog').dialog("close");
                    $("#dialog").remove();
                    ReactDOM.unmountComponentAtNode(document.getElementById('dialogDiv'));
                }
            }
        });
        $("#dialog").dialog("open");
        $('.ui-button').each(function(a){
            if(a!=0){
                $(this).removeClass().addClass("btn btn-primary");
            }
        })
    },
    getInitialState:function(){
        return {selectedItem:new Array(2)}
    },
    render:function(){
        if(this.state.selectedItem[0]!=undefined){
            var targetPath0= this.state.selectedItem[0].props.parent.makeLocationAddress();
        }
        if(this.state.selectedItem[1]!=undefined){
            var targetPath1= this.state.selectedItem[1].props.parent.makeLocationAddress();
        }
        switch (this.props.toDo) {
            case 'makeDir':
            var title="新增資料夾";
            var selecctTitle = (
                <div>
                請點選目的地路徑：
                <DirList className='selectDir' data={this.props.data} toSelect={this.toSelect.bind(null,0)} notDisplayTemplate={true}/>
                </div>
                );
            var targetPath=(
                <div>
                目的地路徑：
                <div className="targetPath">
                {targetPath0}
                </div>
                </div>
                );
            var inputArea=(
                <div>
                請輸入新資料夾名：
                <input type='text' ref="input"/>
                </div>
                );
            break;
            case 'rename':
            var title='重新命名';
            var selecctTitle = (
                <div>
                請點選欲更名檔案：
                <DirList className='selectDir' data={this.props.data} toSelect={this.toSelect.bind(null,0)}/>
                </div>
                );      
            var targetPath=(
                <div>
                目標檔案：
                <div className="targetPath">
                {targetPath0}
                </div>
                </div>
                );
            var inputArea=(
                <div>
                請輸入新命名：
                <input type='text' ref="input"/>
                </div>
                );
            break;
            case 'delete':
            var title='刪除';
            var selecctTitle = (
                <div>
                請點選欲刪除檔案：
                <div className='warning'>
                <span className='glyphicon glyphicon-exclamation-sign' style={{margin:'0px 5px'}}></span>檔案一經刪除後將無法復原
                </div>
                <DirList className='selectDir' data={this.props.data} toSelect={this.toSelectParent.bind(null,0)}/>
                </div>
                );
            break;
            case 'makeTemp':
            var title='新增模板';
            var selecctTitle = (
                <div>
                請點選目的地路徑：
                <DirList className='selectDir' data={this.props.data} toSelect={this.toSelect.bind(null,0)} notDisplayTemplate={true}/>
                </div>
                );                
            var targetPath = (
                <div>
                目的地路徑：
                <div className="targetPath">
                {targetPath0}
                </div>
                </div>
                );
            var inputArea=(
                <div>
                請命名入新模板：
                <input type='text' ref="input"/>
                </div>
                );
            break;
            case 'moveTo':
            var title='移動';
            var selecctTitle = (
                <div className='container-fluid' style={{padding:"0px"}}>
                <div className='row'>
                <div className='col-xs-6' style={{position:'relative'}}>
                請點選目標檔案：
                <DirList className='selectDir' data={this.props.data} toSelect={this.toSelect.bind(null,0)}/>
                <div style={{position:'absolute',right:'-13px',top:'125px'}}> >> </div>
                </div>
                <div className='col-xs-6'>
                請點選目的地路徑：
                <DirList className='selectDir' data={this.props.data} toSelect={this.toSelect.bind(null,1)} notDisplayTemplate={true}/>
                </div>
                </div>

                </div>
                );
            var targetPath = (
                <div>
                <div>
                目標檔案：
                <div className="targetPath">
                {targetPath0}
                </div>
                </div>
                <div>
                移動至：
                <div className="targetPath">
                {targetPath1}
                </div>
                </div>
                </div>
                );
            break;
            default:
            break;
        }
        return(
            <div id='dialog' title={title}>
            {selecctTitle}
            {targetPath}
            {inputArea}
            </div>
            )
    }
});

var DirList=React.createClass({
    render:function(){
        return(
            <div id={this.props.id} className={this.props.className}>
            <DirListItem data={this.props.data} ref='root' loadTemplate={this.props.loadTemplate} toSelect={this.props.toSelect} notDisplayTemplate={this.props.notDisplayTemplate}/>
            </div>
            );
    },
    componentDidMount:function(){
        this.refs.root.drawLine();
    }
});

var DirListItem=React.createClass({
    setStateFromOutside:function(obj){
       this.setState(obj);
    },
    getPath:function(){
        var target=this;
        var path=[];

        while(true){
            path.unshift({type:target.props.data.tagName,name:target.props.data.getAttribute('name')})
            if(target.props.parent!=undefined){
                target=target.props.parent;
            }
            else{
                break;
            }
        }
        return path;
    },
    makeLocationAddress:function(){
    var path=this.getPath();
    var address=[];
    for(var i=0;i<path.length;i++){
        if(path[i].type!='template'){
            var icon=(<span className="glyphicon glyphicon-folder-open" style={{color:'rgb(255, 204, 0)',fontSize:'20px',margin:'0px 5px'}}></span>);
        }
        else{               
            var icon=(<span className="glyphicon glyphicon glyphicon-list-alt" style={{fontSize:'20px',margin:'0px 5px',color:'#1a1a1a'}}></span>);
        }
        address.push((<span key={i*2-1}>{icon}{path[i].name}</span>));
        if(i!=path.length-1){
            address.push((<span key={i*2} style={{margin:'0px 4px'}}>></span>));
        }}
        return address;

    },
    makeXPath:function(){
        var path=this.getPath();
        var xPath='';
        for(var i=0;i<path.length;i++){
            xPath+="/"+path[i].type+"[@name='"+path[i].name+"']";
        }
        return xPath;
    },
    switchDir:function(){
        if(this.state.open){
            this.setState({open:false});
        }
        else{
            this.setState({open:true});
        }
    },
    getInitialState: function() {
        if(this.props.data.tagName=='root'||this.props.data.tagName=='directory'){
            var profiles = this.props.data.childNodes;
            var arr = [];
            for (var key in profiles){
                arr.push(profiles[key]);
            }
            var children=arr.filter(function(children){
                if((children.tagName=='directory')||(children.tagName=='template'&&!this.props.notDisplayTemplate)){
                    return true;     
                }
                else{
                    return false;
                }
            }.bind(this)).sort(function(a,b){
                return a.tagName.charCodeAt(0)-b.tagName.charCodeAt(0);
            }).map(function(children,i){
                return (<DirListItem data={children} key={i} parent={this} loadTemplate={this.props.loadTemplate} toSelect={this.props.toSelect} notDisplayTemplate={this.props.notDisplayTemplate}/>)
            }.bind(this));

            if(children.length!=0){
                if(this.props.data.tagName=='root'){
                    return {open:true,children:children};
                }
                else{
                    return {open:false,children:children};
                }
            }
        }
        return {children:[]};
    },
    drawLine:function(){
        if(this.state.children.length!=0){
            var line=this.refs.childrenNodesDiv.refs.verticalLine;
            var subheight=this.refs.childrenNodesDiv.refs.self.offsetHeight-this.refs.childrenNodesDiv.refs.self.childNodes[this.refs.childrenNodesDiv.refs.self.childNodes.length-1].offsetHeight;

            if(subheight==34){
                line.style.height=subheight+22.5+2+'px';
            }
            else{
                line.style.height=subheight+22.5+'px';
            }

            if(this.props.parent!=undefined){
                this.props.parent.drawLine();                
            }
        }
    },componentWillReceiveProps: function(nextProps) {
        if(nextProps.data.tagName=='root'||nextProps.data.tagName=='directory'){
            var profiles = nextProps.data.childNodes;
            var arr = [];
            for (var key in profiles){
                arr.push(profiles[key]);
            }
            var children=arr.filter(function(children){
                if((children.tagName=='directory')||(children.tagName=='template'&&!nextProps.notDisplayTemplate)){
                    return true;     
                }
                else{
                    return false;
                }
            }.bind(this)).sort(function(a,b){
                return a.tagName.charCodeAt(0)-b.tagName.charCodeAt(0);
            }).map(function(children,i){
                return (<DirListItem data={children} key={i} parent={this} loadTemplate={nextProps.loadTemplate} toSelect={nextProps.toSelect} notDisplayTemplate={nextProps.notDisplayTemplate}/>)
            }.bind(this));
            if(children.length!=0){
                if(this.state.open==undefined){
                    this.setState({open:false,children:children});
                }
                else{
                    this.setState({children:children});
                }
            }
            else{
                this.setState({children:children});
            }

        }
    },
    componentDidUpdate:function(){
        if(this.state.children.length!=0){
            this.drawLine();
        }
    },
    render:function(){
        if(this.state.children.length!=0){
            if(!this.state.open){
                var style={display:'none'};
            }
            else{
                var style={display:'block'};
            }    
            var childrenNodesDiv=(
                <DirListItemChildrenNodesDiv style={style} ref='childrenNodesDiv' children={this.state.children} />
                )
            if(this.props.data.tagName=='directory'){
                var open=this.state.open;
            }
        }
        if(this.state.selected){
            var selected=" selected";
        }
        else{
            var selected='';
        }
        return(
            <div ref='self' className={'DirListItem'+selected}>
            <DirListItemName ref='name' data={this.props.data} hasChildAndOpen={open} switchDir={this.switchDir} toSelect={this.props.toSelect} loadTemplate={this.props.loadTemplate} parent={this}/>
            {childrenNodesDiv}
            </div>
            );
    }
});
var DirListItemChildrenNodesDiv=React.createClass({
    render:function(){
        return(
            <div className='DirListItemChildrenNodesDiv' ref='self' style={this.props.style}>
            <div ref='verticalLine' style={{width:'0px', float: 'left',borderLeft:'1px solid black'}}></div>
            {this.props.children}
            </div>
            );
    }
});

var DirListItemName=React.createClass({
    setStateFromOutside:function(obj){
        this.setState(obj);
    },
    switchButtonClick:function(){
        this.props.switchDir();
    },
    render:function(){
        if(this.props.hasChildAndOpen!=undefined){
            var switchButton=(<button className="directoryMenuSwitch" onClick={this.switchButtonClick}>{this.props.hasChildAndOpen?'-':'+'}</button>);   
        }
        switch(this.props.data.tagName){
            case 'root':
            var style={position:'relative',left:'15px'};
            var icon=(<span className="glyphicon glyphicon-folder-open" style={{color:'rgb(255, 204, 0)',fontSize:'20px',margin:'0px 5px'}}></span>);
            break;
            case 'template':
            var dash=(<span className="dash" style={{padding:'0px',margin:'0px',width:'20px',borderBottom:'black 1px solid'}}>　</span>);
            var icon=(<span className="glyphicon glyphicon glyphicon-list-alt" style={{fontSize:'20px',margin:'0px 5px',color:'#1a1a1a'}}></span>);
            var spanStyle={cursor:'pointer'};
            if(this.props.loadTemplate!=undefined)
                var click=this.props.loadTemplate.bind(null,this.props.data,this.props.parent.makeXPath());
            break;
            case 'directory':
            var dash=(<span className="dash" style={{padding:'0px',margin:'0px',width:'20px',borderBottom:'black 1px solid'}}>　</span>);
            var icon=(<span className="glyphicon glyphicon-folder-open" style={{color:'rgb(255, 204, 0)',fontSize:'20px',margin:'0px 5px'}}></span>);
            break;

            default:
            break;    
        }
        if(this.props.toSelect!=undefined){
            var spanStyle={cursor:'pointer'};
            var click=this.props.toSelect.bind(null,this);
            if(this.state!=null){
                if(this.state.selected){
                    var selected="selected";
                }
            }
        }
        return(
            <div className="DirListItemName" style={style} >
            {dash}
            {switchButton}
            <span style={spanStyle} onClick={click}>
            {icon}
            <span className={selected} ref='txt'>{this.props.data.getAttribute('name')}</span>
            </span>
            </div>
            );
    }
});
var TemplatePanel=React.createClass({
    saveChange:function(nextXPath,oldXPath){
        
        var data=this.state.dataArr.map(function(item,i){
            return {tagName:item.tagName,innerHTML:item.innerHTML}
        });
        var name=this.refs.templateNameInput.value;
        this.setState({mode:'saved'},function(){
            $.ajax({
                url: "templateManage.asmx/changeTempItem",
                type: 'POST',
                async: false,
                data:{argv0:oldXPath,argv1:JSON.stringify(data),argv2:name},
                datatype: 'xml',
                success: function (result) {
                    if(result.getElementsByTagName('error').length!=0){
                   alert(result.getElementsByTagName('error')[0].innerHTML);
                    return;
                }
                    var updateOldXPath=oldXPath.substr(0,oldXPath.lastIndexOf('[@name='))+"[@name='"+name+"']";
                    if(nextXPath==oldXPath){
                        nextXPath=undefined;
                    }
                    this.props.setNewXPath(updateOldXPath);
                    this.props.renewData(result,nextXPath);
                }.bind(this),
                error: function (xhr, status, error) {
                    alert(error);
                }
            });
        });
       
},
newTempDialog:function(index,tagName,innerHTML,callback){
    ReactDOM.render(
    <TempDialog  tagName={tagName} innerHTML={innerHTML} addFunction={this.newTempItem.bind(null,index)}/>,
    document.getElementById('dialogDiv')
    );
    if(callback!=undefined){
        callback();
    }
},
newTempItem:function(index,tagName,innerHTML){
    var item={tagName:tagName,innerHTML:innerHTML};
    if(index==undefined){
        this.state.dataArr.push(item);
    }
    else{
        this.state.dataArr[index]=item;
    }   
    this.setState({dataArr:this.state.dataArr});
},
initialPrviewMode:function(data){
    if(data!=undefined){
        var profiles = data.childNodes;
        var arr = [];
        for (var key in profiles){
            if(profiles[key].nodeType==1){
                arr.push(profiles[key]);
            }
        }
        this.setState({dataArr:arr,mode:'preview'});
    }
},
getInitialState: function(){
    return {dataArr:null,mode:'initial'};
},
componentWillReceiveProps: function(nextProps) {
    if(nextProps.data==undefined||nextProps.xPath==undefined){
        this.setState({mode:'initial',dataArr:null});
    }
    else{
    if(this.state.mode=='edit'){
        var r=window.confirm("是否儲存對\""+this.props.data.getAttribute('name')+"\"的變更？");
        if(r){
            this.saveChange(nextProps.xPath,this.props.xPath);
            
        }
        else{
            this.initialPrviewMode(nextProps.data);
        }
    }
    else{
     this.initialPrviewMode(nextProps.data);
    }
 }
},
enterEditMode:function(){
    this.setState({mode:'edit'});
},
componentDidUpdate:function(){
    $('.ms-parent').each(function(i,n){
        if(n.previousSibling.tagName!='SELECT'){
            n.parentNode.removeChild(n);
        }
    });
    $('#templatePanel select:not([multiple])').multipleSelect({ width: 100, single: true, placeholder: "單選" }).parent().removeAttr('style');
    $('#templatePanel select[multiple]').multipleSelect({ width: 150, placeholder: "多選", selectAll: false, ellipsis: true, countSelected: false }).parent().removeAttr('style');; 
},
swapItem:function(relativeIndex,index,callback){
    var temp=this.state.dataArr[index];
    this.state.dataArr[index]=this.state.dataArr[index+relativeIndex];
    this.state.dataArr[index+relativeIndex]=temp;
    this.setState({dataArr:this.state.dataArr});
    if(callback!=undefined){
        callback();
    }
},
delItem:function(index,callback){
    this.state.dataArr.splice(index,1);
    this.setState({dataArr:this.state.dataArr});
    if(callback!=undefined){
        callback();
    }
},
render:function(){
    switch(this.state.mode){
        case 'initial':
        var initialTxt=(
        <div id="initialTxt">
        尚未選取預覽的模板
        </div>
        );
        break;
        case 'preview':
        var changeModeButtons=(
        <div id="changeModeButtons" className="txtRight">
        <button type="button" className="btn btn-primary" onClick={this.enterEditMode}>進入編輯模式</button>
        </div>
        );
        var templateName=(
        <div id="templateName">{this.props.data.getAttribute('name')}</div>
        );
        var templateContentItem=this.state.dataArr.map(function(item,i){
            return (<TemplateContentItem data={item} key={i} no={i} />)
        });
        var templateContent=(
        <div id="templateContent">{templateContentItem}</div>
        );
        break;
        case 'edit':
        var editButtons=(
        <div id="editButtons" className="txtRight">
        <button id="btnText" type="button" className="btn btn-primary" onClick={this.newTempDialog.bind(null,undefined,'text',undefined,undefined,undefined)}>文字方塊</button>
        <button id="btninputTextBox" type="button" className="btn btn-primary" onClick={this.newTempDialog.bind(null,undefined,'inputTextBox',undefined,undefined)} >文字欄位</button>
        <button id="btnDropdown" type="button" className="btn btn-primary" onClick={this.newTempDialog.bind(null,undefined,'dropdown',undefined,undefined)}>下拉選單（單選）</button>
        <button id="btnDropdown_checkbox" type="button" className="btn btn-primary" onClick={this.newTempDialog.bind(null,undefined,'dropdown_checkbox',undefined,undefined)}>下拉選單（多選）</button>
        <button id="btnImage" type="button" className="btn btn-primary" onClick={this.newTempDialog.bind(null,undefined,'image',undefined,undefined)}>圖片</button>
        <button id="btnLineFeed" type="button" className="btn btn-primary" onClick={this.newTempItem.bind(null,undefined,'lineFeed','')}>換行</button>
        </div>
        );
        var saveButtons=(
        <div id="saveButtons" className="txtRight">
        <button id="btnSave" type="button" className="btn btn-primary" onClick={this.saveChange.bind(null,undefined,this.props.xPath)}>儲存</button>
        <button id="btnCancel" type="button" className="btn btn-primary" onClick={this.initialPrviewMode.bind(null,this.props.data)}>取消</button>
        </div>
        )
        var templateName=(
        <input type="text" defaultValue={this.props.data.getAttribute('name')} id="templateNameInput" ref='templateNameInput' />
        );                        
        var templateContentItem=this.state.dataArr.map(function(moveFunction,delFunction,editFunction,length,item,i){
            if(i==0){var start=true}
                if(i==length-1){var end=true}
                    return (<TemplateContentItem data={item} key={i} no={i} start={start} end={end} editMode={true} backward={moveFunction.bind(null,1,i)} forward={moveFunction.bind(null,-1,i)} del={delFunction.bind(null,i)} edit={editFunction.bind(null,i)}/>);
            }.bind(null,this.swapItem,this.delItem,this.newTempDialog,this.state.dataArr.length));
            var templateContent=(
            <div id="templateContent">{templateContentItem}<div style={{height:'90px'}}></div></div>
            );
            break;
            default:
            break;
        }
        return(
        <div id="templatePanel" className="boundBlock">
        {changeModeButtons}
        {editButtons}
        {initialTxt}
        {templateName}
        {templateContent}
        {saveButtons}
        </div>
        );
    }
});
var TemplateContentItem=React.createClass({
    getEditButtonPanel:function(){
        var tagNameShouldHasEdit=['text','inputTextBox','dropdown','dropdown_checkbox'];
        if(this.props.start==undefined){
            var forward=(
            <button type="button" onClick={this.props.forward.bind(null,this.switchButton)}>往前移</button>
            )
        }
        if(this.props.end==undefined){
            var backward=(
            <button type="button" onClick={this.props.backward.bind(null,this.switchButton)}>往後移</button>
            )
        }
        if(tagNameShouldHasEdit.indexOf(this.props.data.tagName)>-1){
            var edit=(
            <button type="button" onClick={this.props.edit.bind(null,this.props.data.tagName,this.props.data.innerHTML,this.switchButton)}>編輯</button>
            )
        }
        var del=(
        <button type="button" onClick={this.props.del.bind(null,this.switchButton)}>刪除</button>
        )
        var cancel=(
        <button type="button" style={{border:'0px'}} onClick={this.switchButton}>取消</button>
        )


        if(this.state.open!=true){
            var style={display:'none'};
            var styleBack={position:'fixed',width:'100%',height:'100%',zIndex:'11',top:'0px',left:'0px',display:'none'};
        }
        else{
            var styleBack={position:'fixed',width:'100%',height:'100%',zIndex:'11',top:'0px',left:'0px'};
        }

        return (
        <div>
        <div className="editButtonPanel" style={style}>
        <div style={{
            position: 'absolute',
            top:'-19.2px',
            right:'6px',
            width:'0px',
            height:'0px',
            border:'10px solid transparent',
            borderBottomColor:'white',
            zIndex:"6"
        }}></div>
        <div style={{
            position: 'absolute',
            top:'-20.2px',
            right:'6px',
            width:'0px',
            height:'0px',
            border:'10px solid transparent',
            borderBottomColor:'black',
            zIndex:"4"
        }}></div>
        {forward}
        {backward}
        {edit}
        {del}
        {cancel}
        </div>
        <div style={styleBack} onClick={this.switchButton}></div>
        </div>
        )
    },
    getInitialState:function(){
        return {open:false};
    },
    switchButton:function(){
        if(this.state.open!=true){
            this.setState({open:true});
        }
        else{
            this.setState({open:false});               
        }

    },
    render:function(){
        var className="inputDiv";
        if(this.props.editMode!=undefined){
            className+=" editMode";
            var editButtonPanelSwitch=(
            <div className="editButtonPanelSwitch" onClick={this.switchButton}></div> 
            );
            var editButtonPanel=this.getEditButtonPanel();
        }
        switch(this.props.data.tagName){
            case "text":
            var inputArea = (
            <span>
            {this.props.data.innerHTML}
            </span>
            )
            break;

            case "inputTextBox":
            var inputArea = (
            <input type='text' className='inputTextBox' placeholder={this.props.data.innerHTML}/>
            )
            break;

            case "dropdown":
            var items = this.props.data.innerHTML.split(',');
            items.unshift("");
            items=items.filter(function(item,i){
                if(item==''&&i!=0){
                    return false;
                }
                else{
                    return true
                }
            }).map(function(item,i){
                if(item==''){
                    return (<option value={item} key={i}>不選取</option>);
                }
                else{
                    return (<option value={item} key={i}>{item}</option>);
                }
            })
            var inputArea=(
            <select name={this.props.no}>
            {items}
            </select>
            )                   
            break;

            case "dropdown_checkbox":
            var items = this.props.data.innerHTML.split(',');
            items=items.filter(function(item,i){
                if(item==''){
                    return false;
                }
                else{
                    return true;
                }
            }).map(function(item,i){
                return (<option value={item} key={i}>{item}</option>)
            });
            var inputArea=(
            <select multiple name={this.props.no}>
            {items}
            </select>
            )                       
            break;

            case "lineFeed":
            className+=' lineFeed';
            var inputArea=(
            <div className="dotDash"></div>
            )
            break;

            case "image":
            var inputArea=(
            <img src={this.props.data.innerHTML} width='100%' alt='無法連接圖片' />
            )
            break;

            default:
            break;
        }

        return(
        <div className={className}>
        {editButtonPanelSwitch}{editButtonPanel}{inputArea}
        </div>
        );
    }
});
var TempDialog=React.createClass({
    componentDidMount:function(){
        $("#dialog").dialog({
            autoOpen: false,
            width: 650,
            modal: true,
            buttons: {
                '確定': function () {
                    if(this.refs.input.value==''){
                        alert('不可留空');
                        return false;
                    };
                    this.props.addFunction(this.props.tagName,this.refs.input.value);
                    $('#dialog').dialog("close");
                    $("#dialog").remove();
                    ReactDOM.unmountComponentAtNode(document.getElementById('dialogDiv'));
                }.bind(this),
                '取消':function(){
                    $('#dialog').dialog("close");
                    $("#dialog").remove();
                    ReactDOM.unmountComponentAtNode(document.getElementById('dialogDiv'));
                }
            }
        });
        $("#dialog").dialog("open");
    },
    render:function(){
        switch (this.props.tagName) {
            case 'text':
            var title="文字方塊";
            var prompt=(
            <div>
            請輸入文字：
            </div>
            );
            break;
            case 'inputTextBox':
            var title="文字欄位";
            var prompt=(
            <div>
            請輸入預留提示：
            </div>)
            break;
            case 'dropdown':
            var title="下拉選單(單選)";
            var prompt=(
            <div>
            請輸入選項：<div><small>(以逗號分開如 蘋果,香蕉,水蜜桃)</small></div>
            </div>
            );
            break;

            case 'dropdown_checkbox':
            var title="下拉選單(多選)";
            var prompt=(
            <div>
            請輸入選項：<div><small>(以逗號分開如 蘋果,香蕉,水蜜桃)</small></div>
            </div>
            );
            break;
            case 'image':
            var title="圖片";
            var prompt=(
            <div>
            請輸入圖片網址：
            </div>
            );
            default:
            break;
        }
        return (
        <div id='dialog' title={title}>
        {prompt}
        <input ref='input' type='text' style={{width:'90%',margin:'8px 0px'}} defaultValue={this.props.innerHTML}/>
        </div>
        );

    }
});
ReactDOM.render(
    <Root/>,
    document.getElementById('root')
    );
</script>

    
</body>
</html>
