using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace NFramework.Module.UI.ScrollView
{
    public class IconItemList : MonoBehaviour
    {
        public List<IconItem> mItemList;

        public void Init()
        {
            foreach (IconItem item in mItemList)
            {
                item.Init();
            }
        }
    }   
}
