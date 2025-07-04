using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace NFramework.Module.UI.ScrollView
{
    public class NestedListViewLeftToRightDemoScript : MonoBehaviour
    {
        public LoopList mLoopListView;
        public int mTotalDataCount = 100;
        DataSourceMgr<NestedItemData> mDataSourceMgr;
        ButtonPanelNested mButtonPanel;               

        // Use this for initialization
        void Start()
        {
            mDataSourceMgr = new DataSourceMgr<NestedItemData>(mTotalDataCount);
            mLoopListView.InitListView(mDataSourceMgr.TotalItemCount, OnGetItemByIndex);     
            InitButtonPanel();
        }

        void InitButtonPanel()
        {
            mButtonPanel = new ButtonPanelNested();
            mButtonPanel.mLoopListView = mLoopListView;
            mButtonPanel.mDataSourceMgr = mDataSourceMgr;
            mButtonPanel.Start();
        }     

        View OnGetItemByIndex(LoopList listView, int index)
        {
            if (index < 0 || index >= mDataSourceMgr.TotalItemCount)
            {
                return null;
            }

            NestedItemData itemData = mDataSourceMgr.GetItemDataByIndex(index);
            if (itemData == null)
            {
                return null;
            }

            //get a new item. Every item can use a different prefab, the parameter of the NewListViewItem is the prefab’name. 
            //And all the prefabs should be listed in ItemPrefabList in LoopListView2 Inspector Setting
            View item = listView.NewListViewItem("ItemPrefab");
            NestedTopBottomItem itemScript = item.GetComponent<NestedTopBottomItem>();
            if (item.IsInitHandlerCalled == false)
            {
                item.IsInitHandlerCalled = true;
                itemScript.Init();
            }
            itemScript.SetItemData(itemData);
            return item;
        }
    }
}
