using System.Collections.Generic;
using System.IO;
using System.Xml;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Game
{
    public class HierarchyToXML
    {
        public static StringWriter GetDontDestroyOnLoadHierarchyToStr()
        {
            XmlDocument xml = GetCurrentSceneHierarchyToXML();
            StringWriter sw = new StringWriter();
            xml.Save(sw);
            return sw;
        }
        public static XmlDocument GetDontDestroyOnLoadHierarchyToXML()
        {
            // 创建XmlDocument对象
            XmlDocument xmlDoc = new XmlDocument();

            // 创建根元素
            XmlElement root = xmlDoc.CreateElement("Hierarchy");
            xmlDoc.AppendChild(root);

            // 创建场景元素
            XmlElement sceneElement = xmlDoc.CreateElement("Scene");
            sceneElement.SetAttribute("name", "DontDestroyOnLoad");
            root.AppendChild(sceneElement);
            GameObject[] DontDestroyOnLoad = getDontDestroyOnLoadGameObjects();
            foreach (GameObject rootObject in DontDestroyOnLoad)
            {
                AppendGameObject(sceneElement, rootObject, xmlDoc);
            }

            return xmlDoc;
        }
        public static XmlDocument GetCurrentSceneHierarchyToXML()
        {
            // 创建XmlDocument对象
            XmlDocument xmlDoc = new XmlDocument();

            // 创建根元素
            XmlElement root = xmlDoc.CreateElement("Hierarchy");
            xmlDoc.AppendChild(root);

            // 获取当前激活的场景
            var activeScene = UnityEngine.SceneManagement.SceneManager.GetActiveScene();

            // 创建场景元素
            XmlElement sceneElement = xmlDoc.CreateElement("Scene");
            sceneElement.SetAttribute("name", activeScene.name);
            root.AppendChild(sceneElement);
            // 获取所有根对象
            GameObject[] rootObjects = activeScene.GetRootGameObjects();

            // 遍历每个根对象
            foreach (GameObject rootObject in rootObjects)
            {
                AppendGameObject(sceneElement, rootObject, xmlDoc);
            }

            XmlElement sceneElement2 = xmlDoc.CreateElement("Scene");
            sceneElement2.SetAttribute("name", "DontDestroyOnLoad");
            root.AppendChild(sceneElement2);
            GameObject[] DontDestroyOnLoad = getDontDestroyOnLoadGameObjects();
            foreach (GameObject rootObject in DontDestroyOnLoad)
            {
                AppendGameObject(sceneElement2, rootObject, xmlDoc);
            }

            return xmlDoc;
            // // 保存XML文件
            // string filePath = Path.Combine(Application.persistentDataPath, $"{activeScene.name}_Hierarchy.xml");
            // xmlDoc.Save(filePath);
            // Debug.Log("Hierarchy saved to " + filePath);
            // Application.OpenURL(filePath);
        }

        private static GameObject[] getDontDestroyOnLoadGameObjects()
        {
            var allGameObjects = new List<GameObject>();
            allGameObjects.AddRange(GameObject.FindObjectsOfType<GameObject>());
            //移除所有场景包含的对象
            for (var i = 0; i < SceneManager.sceneCount; i++)
            {
                var scene = SceneManager.GetSceneAt(i);
                var objs = scene.GetRootGameObjects();
                for (var j = 0; j < objs.Length; j++)
                {
                    allGameObjects.Remove(objs[j]);
                }
            }

            //移除父级不为null的对象
            int k = allGameObjects.Count;
            while (--k >= 0)
            {
                if (allGameObjects[k].transform.parent != null)
                {
                    allGameObjects.RemoveAt(k);
                }
            }

            return allGameObjects.ToArray();
        }

        private static void AppendGameObject(XmlElement parentElement, GameObject gameObject, XmlDocument xmlDoc)
        {
            // 创建GameObject元素并设置属性
            XmlElement gameObjectElement = xmlDoc.CreateElement("GameObject");
            gameObjectElement.SetAttribute("name", gameObject.name);
            gameObjectElement.SetAttribute("active", gameObject.activeSelf.ToString());
            gameObjectElement.SetAttribute("ChildCount", gameObject.transform.childCount.ToString());

            // 获取Component
            Component[] components = gameObject.GetComponents<Component>();

            // 挂载脚本的数量
            int scriptCount = 0;

            // 创建Components元素
            XmlElement componentsElement = xmlDoc.CreateElement("Components");

            foreach (Component component in components)
            {
                // 检查是否是MonoBehaviour，排除Transform
                if (component is MonoBehaviour monoBehaviour)
                {
                    scriptCount++;
                    XmlElement componentElement = xmlDoc.CreateElement("Component");
                    componentElement.SetAttribute("type", component.GetType().ToString());
                    componentElement.SetAttribute("enabled", monoBehaviour.enabled.ToString());
                    componentsElement.AppendChild(componentElement);
                }
            }

            // 将Components元素添加到GameObject元素
            componentsElement.SetAttribute("scriptCount", scriptCount.ToString());
            gameObjectElement.AppendChild(componentsElement);

            // 将GameObject元素添加到父元素
            parentElement.AppendChild(gameObjectElement);

            // 递归处理子对象
            foreach (Transform child in gameObject.transform)
            {
                AppendGameObject(gameObjectElement, child.gameObject, xmlDoc);
            }
        }
    }
}