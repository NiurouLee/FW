﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace NFramework.Module.UI.ScrollView
{
    public class BaseHorizontalItem : MonoBehaviour
    {
        public Text mNameText;
        public Image mIcon;
        public Image mStarIcon;
        public Text mStarCount;
        public Text mDesc;
        public Color32 mRedStarColor = new Color32(236, 217, 103, 255);
        public Color32 mGrayStarColor = new Color32(215, 215, 215, 255);
        
        int mItemDataIndex = -1;
        ItemData mItemData;
        
        public void Init()
        {
            ClickEventListener listener = ClickEventListener.Get(mStarIcon.gameObject);
            listener.SetClickEventHandler(OnStarClicked);
        }

       void OnStarClicked(GameObject obj)
        {
            if (mItemData.mStarCount >= 99)
            {
                mItemData.mStarCount = 0;
            }
            else
            {
                mItemData.mStarCount = mItemData.mStarCount + 1;
            }
            SetStarCount(mItemData.mStarCount);
        }

        public void SetStarCount(int count)
        {
            mStarCount.text = count.ToString();
            if (count == 0)
            {
                mStarIcon.color = mGrayStarColor;
            }
            else
            {
                mStarIcon.color = mRedStarColor;
            }
        }

        public void SetItemData(ItemData itemData, int itemIndex)
        {
            mItemData = itemData;
            mItemDataIndex = itemIndex;
            mNameText.text = itemData.mName;
            mDesc.text = itemData.mDesc;
            mIcon.sprite = ResManager.Get.GetSpriteByName(itemData.mIcon);
            SetStarCount(itemData.mStarCount);
        }
    }
}
