using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace NFramework.Module.UI.ScrollView
{
    public class ListViewMultiplePrefabDemoScript : MonoBehaviour
    {
        public LoopList mLoopListView;
        public int mTotalDataCount = 10000;       
        DataSourceMgr<ItemData> mDataSourceMgr;
        ButtonPanel mButtonPanel;

        // Use this for initialization
        void Start()
        {
            mDataSourceMgr = new DataSourceMgr<ItemData>(mTotalDataCount);
            mLoopListView.InitListView(mDataSourceMgr.TotalItemCount, OnGetItemByIndex);
            InitButtonPanel();
        }

        void InitButtonPanel()
        {
            mButtonPanel = new ButtonPanel();
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
            ItemData itemData = mDataSourceMgr.GetItemDataByIndex(index);
            if (itemData == null)
            {
                return null;
            }
            View item = null;
            if( index%3 == 0)
            {
                item = listView.NewListViewItem("ItemPrefab1");
                BaseVerticalItem itemScript = item.GetComponent<BaseVerticalItem>();
                if (item.IsInitHandlerCalled == false)
                {
                    item.IsInitHandlerCalled = true;
                    itemScript.Init();
                }
                itemScript.SetItemData(itemData, index);
            }
            else if( index % 3 == 1 )
            {
                item = listView.NewListViewItem("ItemPrefab2");
                SliderItem itemScript = item.GetComponent<SliderItem>();
                if (item.IsInitHandlerCalled == false)
                {
                    item.IsInitHandlerCalled = true;
                    itemScript.Init();
                }
                itemScript.SetItemData(itemData, index);
            }
            else
            {
                item = listView.NewListViewItem("ItemPrefab3");
                InputFieldItem itemScript = item.GetComponent<InputFieldItem>();
                if (item.IsInitHandlerCalled == false)
                {
                    item.IsInitHandlerCalled = true;
                    itemScript.Init();
                }
                itemScript.SetItemData(itemData, index);                
            }            
            return item;
        }        
    }
}
