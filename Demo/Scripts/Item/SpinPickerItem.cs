﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace NFramework.Module.UI.ScrollView
{
    public class SpinPickerItem : MonoBehaviour
    {
        public Text mText;
        public int mValue;

        public void Init()
        {
        }

        public int Value
        {
            get
            {
                return mValue;
            }
            set
            {
                mValue = value;
            }
        }
    }
}
