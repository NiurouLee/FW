﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace NFramework.Module.UI.ScrollView
{
    public class ListViewExpandAnimationDemoScript : MonoBehaviour
    {
        public LoopList mLoopListView;
        public int mTotalDataCount = 10000;
        DataSourceMgr<SimpleExpandItemData> mDataSourceMgr;
        Button mSetCountButton;
        InputField mSetCountInput;
        Button mScrollToButton;
        InputField mScrollToInput;
        Button mAddButton;
        InputField mAddInput;
        Button mBackButton;
        int mCurrentSelectItemId = -1;     
        public ExpandAnimationType mAnimaionType = ExpandAnimationType.Clip;   
        AnimationHelper mAnimationHelper = new AnimationHelper();

        Color[] mItemColorArray;
        int mItemColorCount = 100;
        float mItemColorR = 55.0f;
        float mItemColorG = 58.0f;
        float mItemColorB = 67.0f;
        const float mColorMask = 255.0f;
        const float mColorRangeFrom = 0.0f;
        const float mColorRangeTo = 60.0f;

        // Use this for initialization
        void Start()
        {
            mDataSourceMgr = new DataSourceMgr<SimpleExpandItemData>(mTotalDataCount);
            mLoopListView.InitListView(mDataSourceMgr.TotalItemCount, OnGetItemByIndex);
            InitItemColorArray();
            InitButtonPanel();           
        }

        void InitButtonPanel()
        {
            mSetCountButton = GameObject.Find("ButtonPanel/ButtonGroupSetCount/SetCountButton").GetComponent<Button>();
            mSetCountInput = GameObject.Find("ButtonPanel/ButtonGroupSetCount/SetCountInputField").GetComponent<InputField>();
            mSetCountButton.onClick.AddListener(OnSetCountButtonClicked);

            mScrollToButton = GameObject.Find("ButtonPanel/ButtonGroupScrollTo/ScrollToButton").GetComponent<Button>();
            mScrollToInput = GameObject.Find("ButtonPanel/ButtonGroupScrollTo/ScrollToInputField").GetComponent<InputField>();
            mScrollToButton.onClick.AddListener(OnScrollToButtonClicked);

            mAddButton = GameObject.Find("ButtonPanel/ButtonGroupAdd/AddButton").GetComponent<Button>();
            mAddInput = GameObject.Find("ButtonPanel/ButtonGroupAdd/AddInputField").GetComponent<InputField>();
            mAddButton.onClick.AddListener(OnAddButtonClicked);

            mBackButton = GameObject.Find("ButtonPanel/BackButton").GetComponent<Button>();
            mBackButton.onClick.AddListener(OnBackButtonClicked);
        }  

        void InitItemColorArray()
        {
            mItemColorArray = new Color[mItemColorCount];
            for (int i = 0; i < mItemColorCount; ++i)
            {
                float tmp = Random.Range(mColorRangeFrom, mColorRangeTo);
                float itemColorR = (mItemColorR+tmp)/mColorMask;
                float itemColorG = (mItemColorG+tmp)/mColorMask;
                float itemColorB = (mItemColorB+tmp)/mColorMask;
                mItemColorArray[i] =  new Color(itemColorR, itemColorG, itemColorB, 1.0f);
            }
        }

        View OnGetItemByIndex(LoopList listView, int index)
        {
            if (index < 0 || index >= mDataSourceMgr.TotalItemCount)
            {
                return null;
            }

            SimpleExpandItemData itemData = mDataSourceMgr.GetItemDataByIndex(index);
            if (itemData == null)
            {
                return null;
            }
            //get a new item. Every item can use a different prefab, the parameter of the NewListViewItem is the prefab’name. 
            //And all the prefabs should be listed in ItemPrefabList in LoopListView2 Inspector Setting
            View item = listView.NewListViewItem("ItemPrefab");
            ExpandAnimationItem itemScript = item.GetComponent<ExpandAnimationItem>();
            UpdateItemColor(itemScript,itemData.mId);
            if (item.IsInitHandlerCalled == false)
            {
                item.IsInitHandlerCalled = true;
                itemScript.Init(OnItemClicked,mAnimationHelper);
            }
            item.ItemId = itemData.mId;
            itemScript.SetAnimationType(mAnimaionType);
            itemScript.SetItemData(itemData);
            itemScript.SetItemSelected(mCurrentSelectItemId == itemData.mId);

            float animationValue = mAnimationHelper.GetCurAnimationValue(itemData.mId);
            if(animationValue >= 0)
            {
                itemScript.SetAnimationValue(animationValue);
            }
            return item;
        }        

        void Update()
        {
            mAnimationHelper.UpdateAllAnimation(TimeModule.deltaTime);
            List<int> allAnimationKeys = mAnimationHelper.AllAnimationKeys;
            if(allAnimationKeys.Count > 0)
            {
                foreach(int itemId in allAnimationKeys)
                {
                    float val = mAnimationHelper.GetCurAnimationValue(itemId);
                    View item = mLoopListView.GetShownItemByItemId(itemId);
                    if (item != null)
                    {
                        item.GetComponent<ExpandAnimationItem>().SetAnimationValue(val);
                        mLoopListView.OnItemSizeChanged(item.ItemIndex);
                    }
                    if(mAnimationHelper.IsAnimationFinished(itemId))
                    {
                        mAnimationHelper.RemoveAnimation(itemId);
                    }
                }
            }
        }

        void UpdateItemColor(ExpandAnimationItem itemScript,int id)
        {     
            Transform transform = itemScript.GetComponent<Transform>(); 
            Image imageItemTitle = transform.Find("TitleRoot").GetComponent<Image>();
            imageItemTitle.color = mItemColorArray[id % mItemColorCount];  
            Image imageItemContent = transform.Find("ContentRoot").GetComponent<Image>();
            imageItemContent.color = mItemColorArray[id % mItemColorCount];          
        }

        void OnItemClicked(int itemId)
        {
            mCurrentSelectItemId = itemId;
            mLoopListView.RefreshAllShownItem();
        }

        void OnSetCountButtonClicked()
        {
            int count = 0;
            if (int.TryParse(mSetCountInput.text, out count) == false)
            {
                return;
            }
            if (count < 0)
            {
                return;
            }
            mDataSourceMgr.SetDataTotalCount(count);
            mLoopListView.SetListItemCount(count, false);
            mLoopListView.RefreshAllShownItem();
        }

        void OnScrollToButtonClicked()
        {
            int itemIndex = 0;
            if (int.TryParse(mScrollToInput.text, out itemIndex) == false)
            {
                return;
            }
            if ((itemIndex < 0) || (itemIndex >= mDataSourceMgr.TotalItemCount))
            {
                return;
            }
            mLoopListView.MovePanelToItemIndex(itemIndex, 0);
        }

        void OnAddButtonClicked()
        {
            int itemIndex = 0;
            if (int.TryParse(mAddInput.text, out itemIndex) == false)
            {
                return;
            }
            if ((itemIndex < 0) || (itemIndex > mDataSourceMgr.TotalItemCount))
            {
                return;
            }
            SimpleExpandItemData newData = mDataSourceMgr.InsertData(itemIndex);
            mLoopListView.SetListItemCount(mDataSourceMgr.TotalItemCount, false);
            mLoopListView.RefreshAllShownItem();
        }

        void OnBackButtonClicked()
        {
            ButtonPanelMenuList.BackToMainMenu();
        }
    }
}
