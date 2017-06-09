using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Xml;
using System.Web.Script.Serialization;

namespace template
{
    /// <summary>
    ///handler 的摘要描述
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // 若要允許使用 ASP.NET AJAX 從指令碼呼叫此 Web 服務，請取消註解下列一行。
    [System.Web.Script.Services.ScriptService]

    public class handler : System.Web.Services.WebService
    {
        String xmlLocation = HttpContext.Current.Server.MapPath(@"\assets\template.xml");

        public XmlDocument reportEorror(String error)
        {
            XmlDocument xml = new XmlDocument();
            XmlElement errorNode = xml.CreateElement("error");
            errorNode.InnerText = error;
            xml.AppendChild(errorNode);
            return xml;
        }

        [WebMethod]
        public XmlDocument HelloWorld()
        {
            return reportEorror("Hello World");
        }
        [WebMethod]
        public XmlDocument getTemplateXml()
        {   
            XmlDocument xml = new XmlDocument();
            xml.Load(xmlLocation);
            return xml;
        }
        [WebMethod]
        public XmlDocument makeDir(String argv0, String argv1)
        {
            // argv0 所屬資料夾
            // argv1 新資料夾名

            try
            {
                XmlDocument xml = new XmlDocument();
                xml.Load(xmlLocation);
                XmlElement dirChild = xml.CreateElement("directory");
                dirChild.InnerText = "\n";
                dirChild.SetAttribute("name", argv1);
                XmlNode parentNode = xml.SelectSingleNode(argv0);
                if (parentNode == null)
                {
                    return reportEorror("找不到  路徑為" + argv0);
                }
                else
                
                    if (xml.SelectSingleNode(argv0 + "/directory[@name='" + argv1 + "']") == null){
                        parentNode.AppendChild(dirChild);

                    }
                    else{
                        return reportEorror("已存在相同名稱資料夾");
                    }

                    xml.Save(xmlLocation);
                    return xml;
                

            }
            catch (Exception e)
            {
                return reportEorror(e.ToString());
            }
        }
        [WebMethod]
        public XmlDocument makeTemp(String argv0, String argv1)
        {
            // argv0 所屬資料夾
            // argv1 新模板命名

            
            try
            {
                XmlDocument xml = new XmlDocument();
                xml.Load(xmlLocation);
                XmlElement dirChild = xml.CreateElement("template");
                dirChild.InnerText = "\n";
                dirChild.SetAttribute("name", argv1);
                XmlNode parentNode = xml.SelectSingleNode(argv0);
                if (parentNode == null)
                {
                    return reportEorror("找不到  路徑為" + argv0);
                }
                else

                    if (xml.SelectSingleNode(argv0 + "/template[@name='" + argv1 + "']") == null)
                    {
                        parentNode.AppendChild(dirChild);

                    }
                    else
                    {
                        return reportEorror("已存在相同名稱模板");
                    }

                xml.Save(xmlLocation);
                return xml;


            }
            catch (Exception e)
            {
                return reportEorror(e.ToString());
            }
        }
        [WebMethod]
        public XmlDocument rename(String argv0, String argv1)
        {
            //argv0 目標節點
            //argv1 新命名

            
            try
            {
                XmlDocument xml = new XmlDocument();
                xml.Load(xmlLocation);
                XmlNode node = xml.SelectSingleNode(argv0);
                if (node == null)
                {
                    return reportEorror("找不到  路徑為" + argv0);
                }
                else{ 
                    String str="";
                    String[] array=argv0.Split('/');
                    for(int i=1;i<array.Length-1;i++){
                        
                        str += "/" + array[i];
                    }
                    
                    if(array[array.Length-1].IndexOf("directory")>=0){
                        str+="/directory[@name='" + argv1 + "']";
                    }
                    else if(array[array.Length-1].IndexOf("template")>=0){
                        str+="/template[@name='" + argv1 + "']";
                    }
                    
                    if( xml.SelectSingleNode(str)==null)
                    {
                    node.Attributes["name"].Value = argv1;
                    }
                    else{
                        return reportEorror("已存在相同名稱資料夾");
                    }
                    xml.Save(xmlLocation);
                    return xml;
                }
                

            }
            catch (Exception e)
            {
                return reportEorror(e.ToString());
            }

        }
        
        [WebMethod]
        public XmlDocument delete(String argv0)
        {
            //argv0 刪除節點
            try
            {
                XmlDocument xml = new XmlDocument();
                xml.Load(xmlLocation);
                XmlNode node = xml.SelectSingleNode(argv0);
                if (node == null)
                {
                    return reportEorror("找不到  路徑為" + argv0);
                }
                else
                {                    
                        node.ParentNode.RemoveChild(node);
                }
                xml.Save(xmlLocation);
                return xml;
            }
            catch (Exception e)
            {
                return reportEorror(e.ToString());
            }
        }
        
        [WebMethod]
        public XmlDocument moveTo(String argv0, String argv1)
        {
            //argv0 從何處
            //argv1 移動至
            try
            {
                XmlDocument xml = new XmlDocument();
                xml.Load(xmlLocation);

                XmlNode fromNode = xml.SelectSingleNode(argv0);
                XmlNode toNode = xml.SelectSingleNode(argv1);
                if (fromNode == null)
                {
                    return reportEorror("找不到  路徑為" + argv0);
                }
                else if (toNode == null)
                {
                    return reportEorror("找不到  路徑為" + argv1);
                }
                else if (argv1.IndexOf(argv0) == -1)
                {
                     XmlNode check=xml.SelectSingleNode(argv0 + "/" + argv1.Substring(argv1.LastIndexOf("']/") + 3));
                    if (check==null) {
                        return reportEorror("已有重複節點");
                    }
                    toNode.AppendChild(fromNode);
                    xml.Save(xmlLocation);
                    return xml;

                }
                else
                {
                    return reportEorror("父節點無法移動至子截點");
                }
            }
            catch (Exception e)
            {
                return reportEorror(e.ToString());
            }
        }
        [WebMethod]
        public XmlDocument changeTempItem(String argv0, String argv1,String argv2)
        {
            //argv0 temp路徑
            //argv1 內容
            //argv2 新命名

            try
            {
                XmlDocument xml = new XmlDocument();
                xml.Load(xmlLocation);
                XmlNode temp = xml.SelectSingleNode(argv0);
                if (temp == null)
                {
                    return reportEorror("找不到  路徑為" + argv0);
                }
                //temp.InnerXml = argv1;
                JavaScriptSerializer objSerializer = new JavaScriptSerializer();
                TempElement[] items = objSerializer.Deserialize<TempElement[]>(argv1);
                temp.RemoveAll();
                XmlAttribute attr = xml.CreateAttribute("name");
                attr.Value = argv2;     
                temp.Attributes.SetNamedItem(attr);
                XmlElement x;
                foreach (TempElement t in items) {
                    x = xml.CreateElement(t.tagName);
                    if (t.innerHTML != "")
                    {
                        x.InnerText = t.innerHTML;
                    }
                    temp.AppendChild(x);
                }
                xml.Save(xmlLocation);
                return xml;
                
            }
            catch (Exception e)
            {
                return reportEorror(e.ToString());
            }
        }
    }
}
public class TempElement
{
    public string tagName { get; set; }
    public string innerHTML { get; set; }
}