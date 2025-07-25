﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace NFramework.Module.UI.ScrollView
{
    public class InputFieldItemList : MonoBehaviour
    {
        public List<InputFieldItem> mItemList;

        public void Init()
        {
            foreach (InputFieldItem item in mItemList)
            {
                item.Init();
            }
        }
    }   
}
