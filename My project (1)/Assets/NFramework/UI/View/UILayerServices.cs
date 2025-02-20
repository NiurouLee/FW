using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UnityEngine;

namespace NFramework.UI
{
    public class UILayerServices
    {
        public static short OneUiSortOder = 50;
        private UIlayer layer;
        private GameObject go;
        public int BaseOrder { get; private set; }
        private List<Window> stack;
        private Stack<Window> exclusionStack;

        public UILayerServices(UIlayer inLayer, GameObject inGo)
        {
            this.layer = inLayer;
            this.go = inGo;
            BaseOrder = (int)inLayer * 1000;
            stack = new List<Window>();
            exclusionStack = new Stack<Window>();
        }

        

    }
}