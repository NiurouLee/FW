﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace NFramework.Module.UI.ScrollView
{
    public class DraggableViewTopToBottomDemoScript : MonoBehaviour
    {
        public LoopList mLoopListView;
        public int mTotalDataCount = 10000;

        DataSourceMgr<DraggableItemData> mDataSourceMgr;
        Button mBackButton;

        Vector2 mDragOffset;
        float mAnimMoveSpeed = 800;
        float mListViewMoveSpeed = 600;
        float mListViewMoveVec = 0;
        View mDraggingItem;
        Camera mCachedEventCamera;
        List<TweenHelper> mCurTweenHelperList = new List<TweenHelper>();
        Vector3[] mItemWorldCorners = new Vector3[4];

        // Use this for initialization
        void Start()
        {
            mDataSourceMgr = new DataSourceMgr<DraggableItemData>(mTotalDataCount);
            mLoopListView.InitListView(mDataSourceMgr.TotalItemCount, OnGetItemByIndex);
            InitButtonPanel();
        }

        void InitButtonPanel()
        {
            mBackButton = GameObject.Find("ButtonPanel/BackButton").GetComponent<Button>();
            mBackButton.onClick.AddListener(OnBackButtonClicked);
        }

        View OnGetItemByIndex(LoopList listView, int index)
        {
            if (index < 0 || index >= mDataSourceMgr.TotalItemCount)
            {
                return null;
            }
            //get the data to showing
            DraggableItemData itemData = mDataSourceMgr.GetItemDataByIndex(index);
            if (itemData == null)
            {
                return null;
            }
            /*get a new item. Every item can use a different prefab, 
             the parameter of the NewListViewItem is the prefab’name. 
            And all the prefabs should be listed in ItemPrefabList in LoopListView2 Inspector Setting*/
            View item = listView.NewListViewItem("ItemPrefab");
            //get your own component
            DraggableVerticalItem itemScript = item.GetComponent<DraggableVerticalItem>();
            //IsInitHandlerCalled is false means this item is new created but not fetched from pool.
            if (item.IsInitHandlerCalled == false)
            {
                item.IsInitHandlerCalled = true;
                itemScript.Init();// here to init the item, such as add button click event listener.
                DragEventHelperEx deh = itemScript.mDragBar.AddComponent<DragEventHelperEx>();
                deh.Param = item;
                deh.mOnBeginDragHandler = OnBeginDragItem;
                deh.mOnDragHandler = OnDragItem;
                deh.mOnEndDragHandler = OnEndDragItem;
            }
            CanvasGroup canvasGroup = item.gameObject.GetComponent<CanvasGroup>();
            if(mDraggingItem != null && mDraggingItem.ItemIndex == index)
            {
                canvasGroup.alpha = 0;
            }
            else
            {
                canvasGroup.alpha = 1;
            }
            //update the item’s content for showing, such as image,text.
            itemScript.SetItemData(itemData, index);
            return item;
        }

        public void OnBeginDragItem(PointerEventData eventData, object param)
        {
            mCachedEventCamera = eventData.pressEventCamera;
            if (mCurTweenHelperList.Count > 0)
            {
                return;
            }
            View draggingItem = param as View;
            mLoopListView.ScrollRect.StopMovement();
            View orignFirstItem = mLoopListView.GetShownItemByIndex(0);
            if (orignFirstItem == null)
            {
                return;
            }

            mDraggingItem = draggingItem;
            //clone the dragging item.
            View newItem = mLoopListView.NewListViewItem(draggingItem.ItemPrefabName);
            newItem.ItemId = draggingItem.ItemId;
            newItem.ItemIndex = draggingItem.ItemIndex;
            newItem.ItemPrefabName = draggingItem.ItemPrefabName;
            DraggableVerticalItem itemScript = newItem.GetComponent<DraggableVerticalItem>();
            DraggableItemData itemData = mDataSourceMgr.GetItemDataByIndex(mDraggingItem.ItemIndex);
            itemScript.SetItemData(itemData, newItem.ItemIndex);
            int indexInShownItemList = mLoopListView.GetIndexInShownItemList(draggingItem);
            //replace the shown item with the new created clone item.
            mLoopListView.SetShownItemByIndex(indexInShownItemList, newItem);
            CanvasGroup canvasGroup = newItem.gameObject.GetComponent<CanvasGroup>();
            canvasGroup.alpha = 0;
            mDraggingItem.CachedRectTransform.SetParent(mLoopListView.ViewPortTrans);

            RectTransform rtf = draggingItem.CachedRectTransform;
            Vector2 localPos;
            if (RectTransformUtility.ScreenPointToLocalPointInRectangle(rtf, eventData.position, eventData.pressEventCamera, out localPos))
            {
                mDragOffset = localPos;
            }
            SetDraggedPosition(eventData, draggingItem);
            rtf.SetAsLastSibling();
        }


        public void OnDragItem(PointerEventData eventData, object param)
        {
            if (mCurTweenHelperList.Count > 0)
            {
                return;
            }
            View draggingItem = param as View;
            SetDraggedPosition(eventData, draggingItem);


            draggingItem.CachedRectTransform.GetWorldCorners(mItemWorldCorners);
            Vector3 topPos = mLoopListView.ViewPortTrans.InverseTransformPoint(mItemWorldCorners[1]);
            Vector3 downPos = mLoopListView.ViewPortTrans.InverseTransformPoint(mItemWorldCorners[0]);

            if (mLoopListView.ArrangeType == ListItemArrangeType.TopToBottom)
            {
                mListViewMoveVec = 0;
                if (topPos.y > 0)
                {
                    mListViewMoveVec = -mListViewMoveSpeed;
                }
                else if (downPos.y < -mLoopListView.ViewPortHeight)
                {
                    mListViewMoveVec = mListViewMoveSpeed;
                }
            }
            else
            {
                mListViewMoveVec = 0;
                Vector2 localPos;
                if (RectTransformUtility.ScreenPointToLocalPointInRectangle(mLoopListView.ViewPortTrans, eventData.position, eventData.pressEventCamera, out localPos))
                {
                    if (topPos.y > mLoopListView.ViewPortHeight)
                    {
                        mListViewMoveVec = mListViewMoveSpeed;
                    }
                    else if (downPos.y < 0)
                    {
                        mListViewMoveVec = -mListViewMoveSpeed;
                    }
                }
            }

        }


        void Update()
        {
            if (Mathf.Abs(mListViewMoveVec) > 1)
            {
                float offset = mListViewMoveVec * UnityEngine.Time.deltaTime;
                mLoopListView.MovePanelByOffset(offset);
            }
            if(mCurTweenHelperList.Count > 0)
            {
                bool isFinished = false;
                foreach (TweenHelper tweenHelper in mCurTweenHelperList)
                {
                    isFinished = tweenHelper.DoUpdate();
                }
                if(isFinished)
                {
                    OnTweenFinished();
                    mCurTweenHelperList.Clear();
                }
            }
        }

        public void OnEndDragItem(PointerEventData eventData, object param)
        {
            mListViewMoveVec = 0;
            if (mCurTweenHelperList.Count > 0)
            {
                return;
            }
            mCurTweenHelperList.Clear();
            View draggingItem = param as View;
            SetDraggedPosition(eventData, draggingItem);

            int count = mLoopListView.ShownItemCount;
            if (count == 0)
            {
                return;
            }
            Vector3 draggingItemPos =  mLoopListView.ContainerTrans.InverseTransformPoint(draggingItem.CachedRectTransform.position);

            float selfPosY = draggingItemPos.y;
            int selfIndex = draggingItem.ItemIndex;
            int selfIndexInShownItems = mLoopListView.GetIndexInShownItemList(draggingItem);
            int insertBeforeIndex = -1;

            if (mLoopListView.ArrangeType == ListItemArrangeType.TopToBottom)
            {
                float draggingItemMiddleY = draggingItemPos.y - draggingItem.ItemSize/2;
                View curItem = mLoopListView.GetShownItemByIndex(0);
                float curY = curItem.TopY;
                float curMinDist = Mathf.Abs(draggingItemMiddleY - curY);
                insertBeforeIndex = curItem.ItemIndex;
                for (int i = 0; i < count; ++i)
                {
                    curItem = mLoopListView.GetShownItemByIndex(i);
                    curY = curY - curItem.ItemSizeWithPadding;
                    float dist = Mathf.Abs(draggingItemMiddleY - curY);
                    if(curMinDist > dist)
                    {
                        curMinDist = dist;
                        insertBeforeIndex = curItem.ItemIndex+ 1;
                    }
                }
            }
            else
            {
                float draggingItemMiddleY = draggingItemPos.y + draggingItem.ItemSize / 2;
                View curItem = mLoopListView.GetShownItemByIndex(0);
                float curY = curItem.BottomY;
                float curMinDist = Mathf.Abs(draggingItemMiddleY - curY);
                insertBeforeIndex = curItem.ItemIndex;
                for (int i = 0; i < count; ++i)
                {
                    curItem = mLoopListView.GetShownItemByIndex(i);
                    curY = curY + curItem.ItemSizeWithPadding;
                    float dist = Mathf.Abs(draggingItemMiddleY - curY);
                    if (curMinDist > dist)
                    {
                        curMinDist = dist;
                        insertBeforeIndex = curItem.ItemIndex + 1;
                    }
                }
            }

            mDraggingItem.CachedRectTransform.SetParent(mLoopListView.ContainerTrans);
            mDraggingItem.CachedRectTransform.SetAsLastSibling();

            if (insertBeforeIndex == draggingItem.ItemIndex || insertBeforeIndex == (draggingItem.ItemIndex+1))
            {
                mLoopListView.RecycleItemImmediately(mDraggingItem);
                mDraggingItem = null;
                mLoopListView.RefreshAllShownItem();
                return;
            }


            if (mLoopListView.ArrangeType == ListItemArrangeType.TopToBottom)
            {
                if (insertBeforeIndex < draggingItem.ItemIndex)
                {
                    int targetIndex = insertBeforeIndex;
                    View targetItem = mLoopListView.GetShownItemByItemIndex(targetIndex);
                    draggingItem.CachedRectTransform.anchoredPosition3D = targetItem.CachedRectTransform.anchoredPosition3D;
                    int targetIndexInShownItems = mLoopListView.GetIndexInShownItemList(targetItem);
                    for (int i = targetIndexInShownItems; i < count; ++i)
                    {
                        View item = mLoopListView.GetShownItemByIndex(i);
                        if(item.ItemIndex == selfIndex)
                        {
                            break;
                        }
                        item.ItemIndex += 1;
                        TweenHelper tweener = TweenHelper.TweenAnchorPosY(item.CachedRectTransform, item.CachedRectTransform.anchoredPosition3D.y - draggingItem.ItemSizeWithPadding, mAnimMoveSpeed);
                        mCurTweenHelperList.Add(tweener);
                    }
                   

                    DraggableItemData tData = mDataSourceMgr.GetItemDataByIndex(selfIndex);
                    mDataSourceMgr.RemoveData(selfIndex);
                    mDataSourceMgr.InsertData(targetIndex, tData);
                }
                else
                {
                    int targetIndex = insertBeforeIndex -1;
                    View targetItem = mLoopListView.GetShownItemByItemIndex(targetIndex);
                    float newPosY = targetItem.CachedRectTransform.anchoredPosition3D.y - targetItem.ItemSizeWithPadding + draggingItem.ItemSizeWithPadding;
                    Vector3 newPos = targetItem.CachedRectTransform.anchoredPosition3D;
                    newPos.y = newPosY;
                    draggingItem.CachedRectTransform.anchoredPosition3D = newPos;
                    int targetIndexInShownItems = mLoopListView.GetIndexInShownItemList(targetItem);
                    for (int i = targetIndexInShownItems; i >=0 ; --i)
                    {
                        View item = mLoopListView.GetShownItemByIndex(i);
                        if (item.ItemIndex == selfIndex)
                        {
                            break;
                        }
                        item.ItemIndex -= 1;
                        TweenHelper tweener = TweenHelper.TweenAnchorPosY(item.CachedRectTransform, item.CachedRectTransform.anchoredPosition3D.y + draggingItem.ItemSizeWithPadding, mAnimMoveSpeed);
                        mCurTweenHelperList.Add(tweener);
                    }
                   

                    DraggableItemData tData = mDataSourceMgr.GetItemDataByIndex(selfIndex);
                    mDataSourceMgr.InsertData(targetIndex + 1, tData);
                    mDataSourceMgr.RemoveData(selfIndex);
                }
            }
            else
            {
                if (insertBeforeIndex < draggingItem.ItemIndex)
                {
                    int targetIndex = insertBeforeIndex;
                    View targetItem = mLoopListView.GetShownItemByItemIndex(targetIndex);
                    draggingItem.CachedRectTransform.anchoredPosition3D = targetItem.CachedRectTransform.anchoredPosition3D;
                    int targetIndexInShownItems = mLoopListView.GetIndexInShownItemList(targetItem);
                    for (int i = targetIndexInShownItems; i < count; ++i)
                    {
                        View item = mLoopListView.GetShownItemByIndex(i);
                        if (item.ItemIndex == selfIndex)
                        {
                            break;
                        }
                        item.ItemIndex += 1;
                        TweenHelper tweener = TweenHelper.TweenAnchorPosY(item.CachedRectTransform, item.CachedRectTransform.anchoredPosition3D.y + draggingItem.ItemSizeWithPadding, mAnimMoveSpeed);
                        mCurTweenHelperList.Add(tweener);
                    }


                    DraggableItemData tData = mDataSourceMgr.GetItemDataByIndex(selfIndex);
                    mDataSourceMgr.RemoveData(selfIndex);
                    mDataSourceMgr.InsertData(targetIndex, tData);
                }
                else
                {
                    int targetIndex = insertBeforeIndex - 1;
                    View targetItem = mLoopListView.GetShownItemByItemIndex(targetIndex);
                    float newPosY = targetItem.CachedRectTransform.anchoredPosition3D.y + targetItem.ItemSizeWithPadding - draggingItem.ItemSizeWithPadding;
                    Vector3 newPos = targetItem.CachedRectTransform.anchoredPosition3D;
                    newPos.y = newPosY;
                    draggingItem.CachedRectTransform.anchoredPosition3D = newPos;
                    int targetIndexInShownItems = mLoopListView.GetIndexInShownItemList(targetItem);
                    for (int i = targetIndexInShownItems; i >= 0; --i)
                    {
                        View item = mLoopListView.GetShownItemByIndex(i);
                        if (item.ItemIndex == selfIndex)
                        {
                            break;
                        }
                        item.ItemIndex -= 1;
                        TweenHelper tweener = TweenHelper.TweenAnchorPosY(item.CachedRectTransform, item.CachedRectTransform.anchoredPosition3D.y - draggingItem.ItemSizeWithPadding, mAnimMoveSpeed);
                        mCurTweenHelperList.Add(tweener);
                    }


                    DraggableItemData tData = mDataSourceMgr.GetItemDataByIndex(selfIndex);
                    mDataSourceMgr.InsertData(targetIndex + 1, tData);
                    mDataSourceMgr.RemoveData(selfIndex);
                }
            }
        }

        void OnTweenFinished()
        {
            mLoopListView.RecycleItemImmediately(mDraggingItem);
            mDraggingItem = null;
            mLoopListView.RefreshAllShownItem();
        }

        void SetDraggedPosition(PointerEventData eventData,View draggingItem)
        {
            RectTransform rtf = draggingItem.CachedRectTransform;
            Vector2 localPos;
            if (RectTransformUtility.ScreenPointToLocalPointInRectangle(mLoopListView.ViewPortTrans, eventData.position, eventData.pressEventCamera, out localPos))
            {
                Vector2 old = rtf.anchoredPosition;
                if (mLoopListView.IsVertList)
                {
                    old.y = localPos.y - mDragOffset.y;
                }
                else
                {
                    old.x = localPos.x - mDragOffset.x;
                }
                rtf.anchoredPosition = old;
            }
        }

        void OnBackButtonClicked()
        {
            ButtonPanelMenuList.BackToMainMenu();
        }
    }
}
