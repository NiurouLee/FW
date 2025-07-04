using System;
using System.Collections.Generic;
using UnityEngine;
using NFramework.Module.UI;
using View = NFramework.Module.UI.View;

namespace NFramework.Module.UI.ScrollView
{
    public class LoopViewItemPool
    {
        GameObject mPrefabObj;
        string mPrefabName;
        int mInitCreateCount = 1;
        float mPadding = 0;
        float mStartPosOffset = 0;
        List<Module.UI.View> mTmpPooledItemList = new List<Module.UI.View>();
        List<Module.UI.View> mPooledItemList = new List<Module.UI.View>();
        static int mCurItemIdCount = 0;
        RectTransform mItemParent = null;
        Func<GameObject, Module.UI.View> mCreateItemFunc;
        Module.UI.View mParentView;
        public float Padding { get { return mPadding; } }
        public float StartPosOffset { get { return mStartPosOffset; } }
        public Module.UI.View ParentView { get { return mParentView; } }
        public LoopViewItemPool()
        {

        }
        public void Init(GameObject prefabObj, float padding, float startPosOffset, int createCount, RectTransform parent, Func<GameObject, Module.UI.View> createItemFunc, Module.UI.View parentView)
        {
            mPrefabObj = prefabObj;
            mPrefabName = mPrefabObj.name;
            mInitCreateCount = createCount;
            mPadding = padding;
            mStartPosOffset = startPosOffset;
            mItemParent = parent;
            mCreateItemFunc = createItemFunc;
            mPrefabObj.SetActive(false);
            for (int i = 0; i < mInitCreateCount; ++i)
            {
                Module.UI.View tViewItem = CreateItem();
                RecycleItemReal(tViewItem);
            }
        }
        public Module.UI.View GetItem(int itemIndexForSearch)
        {
            mCurItemIdCount++;
            Module.UI.View tItem = null;
            if (mTmpPooledItemList.Count > 0)
            {
                var count = mTmpPooledItemList.Count;
                tItem = mTmpPooledItemList[count - 1];
                mTmpPooledItemList.RemoveAt(count - 1);
            }
            else
            {
                int count = mPooledItemList.Count;
                if (count == 0)
                {
                    tItem = CreateItem();
                }
                else
                {
                    tItem = mPooledItemList[count - 1];
                    mPooledItemList.RemoveAt(count - 1);
                }
            }
            return tItem;

        }

        public void DestroyAllItem()
        {
            ClearTmpRecycledItem();
            int count = mPooledItemList.Count;
            for (int i = 0; i < count; ++i)
            {
                mParentView.RemoveSubView(mPooledItemList[i]);
            }
            mPooledItemList.Clear();
        }
        public Module.UI.View CreateItem()
        {

            GameObject go = GameObject.Instantiate<GameObject>(mPrefabObj, Vector3.zero, Quaternion.identity, mItemParent);
            go.SetActive(true);
            RectTransform rf = go.GetComponent<RectTransform>();
            rf.localScale = Vector3.one;
            rf.anchoredPosition3D = Vector3.zero;
            rf.localEulerAngles = Vector3.zero;
            Module.UI.View tViewItem = mCreateItemFunc(go);
            return tViewItem;
        }
        public void RecycleItemReal(Module.UI.View item)
        {
            item.Facade.NotVisible();
            mPooledItemList.Add(item);
        }
        public void RecycleItem(Module.UI.View item)
        {
            mTmpPooledItemList.Add(item);
        }
        public void ClearTmpRecycledItem()
        {
            int count = mTmpPooledItemList.Count;
            if (count == 0)
            {
                return;
            }
            for (int i = 0; i < count; ++i)
            {
                RecycleItemReal(mTmpPooledItemList[i]);
            }
            mTmpPooledItemList.Clear();
        }
    }
}
