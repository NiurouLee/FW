using System.Numerics;
using System;
using System.Collections.Generic;
using GameObject = UnityEngine.GameObject;
using Vector3 = UnityEngine.Vector3;
using UnityEngine;
using UnityEngine.EventSystems;
using Unity.VisualScripting;
using UnityEngine.UI;

namespace NFramework.Module.UI
{
    public partial class UIM
    {
        private GameObject uiRoot;
        public Camera UICamera { get; private set; }
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
            UICamera = uiRoot.GetComponent<Camera>();
            // uiCamera.tag = "UICamera";
            uiCanvasTrf = uiRoot.transform.Find("Canvas");
            uiCanvas = uiCanvasTrf.GetComponent<Canvas>();
            eventSystem = uiRoot.GetComponentInChildren<EventSystem>();
            scaler = this.uiCanvas.GetOrAddComponent<CanvasScaler>();
        }



    }
}