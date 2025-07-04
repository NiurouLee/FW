using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace NFramework.Module.UI.ScrollView
{
    public class GridViewDiagonalSelectDeleteDemoScript : MonoBehaviour
    {
        public LoopGrid mLoopGridView;
        public int mTotalDataCount = 10000;
        DataSourceMgr<ItemData> mDataSourceMgr;
        ButtonPanelGridViewDelete mButtonPanel;

        // Use this for initialization
        void Start()
        {
            mDataSourceMgr = new DataSourceMgr<ItemData>(mTotalDataCount);
            mLoopGridView.InitGridView(mDataSourceMgr.TotalItemCount, OnGetItemByRowColumn);
            InitButtonPanel();
        }

        void InitButtonPanel()
        {
            mButtonPanel = new ButtonPanelGridViewDelete();
            mButtonPanel.mLoopGridView = mLoopGridView;
            mButtonPanel.mDataSourceMgr = mDataSourceMgr;
            mButtonPanel.Start();
        }     

        LoopGridViewItem OnGetItemByRowColumn(LoopGrid gridView, int index, int row, int column)
        {
            if (index < 0)
            {
                return null;
            }
            
            ItemData itemData = mDataSourceMgr.GetItemDataByIndex(index);
            if (itemData == null)
            {
                return null;
            }
            LoopGridViewItem item = gridView.NewListViewItem("ItemPrefab");
            ToggleRowColItem itemScript = item.GetComponent<ToggleRowColItem>();
            if (item.IsInitHandlerCalled == false)
            {
                item.IsInitHandlerCalled = true;
                itemScript.Init();
            }
            itemScript.SetItemData(itemData, index, row, column);
            return item;
        }     
    }
}
