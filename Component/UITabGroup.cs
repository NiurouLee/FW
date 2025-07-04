﻿using System;
using System.Collections.Generic;
using UnityEngine.UI;

namespace Ez.UI
{
    public class UITabGroup:ToggleGroup
    {
        public List<UITab> tabs;

        public Action<bool, string> OnChangeCallBack
        {
            set
            {
                if (tabs!=null)
                {
                    foreach (UITab t in tabs)
                    {
                        t.toggle.group = this;
                        t.onValueChange = value;
                    }
                }
            }
        }

        protected override void Awake()
        {
            base.Awake();
            if (tabs!=null)
            {
                foreach (UITab t in tabs)
                {
                    t.toggle.group = this;
                }
            }
        }

        protected override void Start()
        {
            base.Start();

        }

        public UITab CurrentTab
        {
            get
            {
                if (tabs!=null)
                {
                    foreach (UITab t in tabs)
                    {
                        if (t.toggle.isOn)
                        {
                            return t;
                        }
                    }
                }
                return null;
            }
        }

        /// <summary>
        /// 设置当前激活的tab 根据绑定数据内的data数据
        /// </summary>
        /// <param name="tabdata"></param>
        public void SetCurrentTab(string  tabdata)
        {
            if (tabs != null)
            {
                foreach (UITab t in tabs)
                {
                    if (t.data == tabdata)

                    {
                        t.toggle.isOn = true;
                        break;
                    }
                }

            }
        }
    }
}