using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace NFramework.Module.UI.ScrollView
{
    public class BaseVerticalItemList : MonoBehaviour
    {
        public List<BaseVerticalItem> mItemList;

        public void Init()
        {
            foreach (BaseVerticalItem item in mItemList)
            {
                item.Init();
            }
        }
    }   
}
