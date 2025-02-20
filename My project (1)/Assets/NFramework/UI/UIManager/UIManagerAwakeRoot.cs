using System.Numerics;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using GameObject = UnityEngine.GameObject;
using Vector3 = UnityEngine.Vector3;
using UnityEngine;
using UnityEngine.EventSystems;
using Unity.VisualScripting;
using UnityEngine.UI;
using NFramework.Utils;

namespace NFramework.UI
{
    public partial class UIManager
    {
        private GameObject uiRoot;
        private Camera uiCamera;
        private Canvas uiCanvas;
        private Transform uiCanvasTrf;
        private EventSystem eventSystem;
        private CanvasScaler scaler;

        public void AwakeRoot(GameObject inRoot)
        {
            uiRoot = inRoot;
            uiRoot.transform.localPosition = new Vector3(0, 1000, 0);
            uiRoot.name = "[UIROOT]";
            GameObject.DontDestroyOnLoad(uiRoot);
            uiCamera = uiRoot.GetComponent<Camera>();
            uiCamera.tag = "UICamera";
            uiCanvasTrf = uiRoot.transform.Find("Canvas");
            uiCanvas = uiCanvasTrf.GetComponent<Canvas>();
            eventSystem = uiRoot.GetComponentInChildren<EventSystem>();
            scaler = this.uiCanvas.GetOrAddComponent<CanvasScaler>();
        }

        private Dictionary<UIlayer, UILayerServices> layerServices = new Dictionary<UIlayer, UILayerServices>();

        public void AwakeLayer()
        {
            foreach (var item in System.Enum.GetValues(typeof(UIlayer)))
            {
                UIlayer _ilayer = (UIlayer)item;
                var go = new GameObject(item.ToString());
                var trans = go.AddComponent<RectTransform>();
                trans.SetParent(uiCanvasTrf, false);
                TransformUtils.NormalizeRectTransform(trans);
                // go.AddComponent<>
                //todo: 适配 
                UILayerServices services = new UILayerServices(_ilayer, go);
                this.layerServices.Add(_ilayer, services);
            }
        }
    }
}