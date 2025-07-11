﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

namespace NFramework.Module.UI.ScrollView
{
    public class DragChangSizeScript :MonoBehaviour, IBeginDragHandler, IEndDragHandler, IDragHandler,
		IPointerEnterHandler, IPointerExitHandler
    {
        bool mIsDragging = false;
        public Camera mCamera;
        public float mBorderSize = 10;
        public Texture2D mCursorTexture;
        public Vector2 mCursorHotSpot = new Vector2(16, 16);
        public bool mIsVertical = false;
        RectTransform mCachedRectTransform;
        RectTransform mRootCanvasRectTransform;
        float mMinWidth = 200;
        float mMinHeight = 200;

        public System.Action mOnDragBeginAction;
        public System.Action mOnDraggingAction;
        public System.Action mOnDragEndAction;

        public RectTransform CachedRectTransform
        {
            get
            {
                if (mCachedRectTransform == null)
                {
                    mCachedRectTransform = gameObject.GetComponent<RectTransform>();
                }
                return mCachedRectTransform;
            }
        }

        public void OnPointerEnter(PointerEventData eventData)
        {
            SetCursor(mCursorTexture, mCursorHotSpot, CursorMode.Auto);
        }

        public void OnPointerExit(PointerEventData eventData)
        {
            SetCursor(null, mCursorHotSpot, CursorMode.Auto);
        }

        void SetCursor(Texture2D texture, Vector2 hotspot, CursorMode cursorMode)
        {
            if (Input.mousePresent)
            {
                Cursor.SetCursor(texture, hotspot, cursorMode);
            }
        }

         Canvas GetRootCanvas()
        {
            List<Canvas> list = new List<Canvas>();
            gameObject.GetComponentsInParent(false, list);
            if (list.Count == 0)
            {
                return null;
            }
            var listCount = list.Count;
            Canvas rootCanvas = list[listCount - 1];
            for (int i = 0; i < listCount; i++)
            {
                if (list[i].isRootCanvas || list[i].overrideSorting)
                {
                    rootCanvas = list[i];
                    break;
                }
            }
            return rootCanvas;
        }

        void Start()
        {
            Canvas rootCanvas = GetRootCanvas();
            mRootCanvasRectTransform = rootCanvas.GetComponent<RectTransform>();
        }

        void LateUpdate()
        {
            if (mCursorTexture == null)
            {
                return;
            }
            
            if(mIsDragging)
            {
                SetCursor(mCursorTexture, mCursorHotSpot, CursorMode.Auto);
                return;
            }

            Vector2 point;
            if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(CachedRectTransform, Input.mousePosition, mCamera, out point))
            {
                SetCursor(null, mCursorHotSpot, CursorMode.Auto);
                return;
            }
            if(mIsVertical)
            {
                float d = CachedRectTransform.rect.height + point.y;
                if (d < 0)
                {
                    SetCursor(null, mCursorHotSpot, CursorMode.Auto);
                }
                else if (d <= mBorderSize)
                {
                    SetCursor(mCursorTexture, mCursorHotSpot, CursorMode.Auto);
                }
                else
                {
                    SetCursor(null, mCursorHotSpot, CursorMode.Auto);
                }
            }
            else
            {
                float d = CachedRectTransform.rect.width - point.x;
                if (d < 0)
                {
                    SetCursor(null, mCursorHotSpot, CursorMode.Auto);
                }
                else if (d <= mBorderSize)
                {
                    SetCursor(mCursorTexture, mCursorHotSpot, CursorMode.Auto);
                }
                else
                {
                    SetCursor(null, mCursorHotSpot, CursorMode.Auto);
                }
            }            

        }

        public void OnBeginDrag(PointerEventData eventData)
        {
            mIsDragging = true;
            if(mOnDragBeginAction != null)
            {
                mOnDragBeginAction();
            }
        }

        public void OnEndDrag(PointerEventData eventData)
        {
            mIsDragging = false;
            if(mOnDragEndAction != null)
            {
                mOnDragEndAction();
            }
        }

        public void OnDrag(PointerEventData eventData)
        {
            if (!RectTransformUtility.RectangleContainsScreenPoint(mRootCanvasRectTransform, eventData.position, mCamera))
            {
                return;
            }

            Vector2 p1;
            if(!RectTransformUtility.ScreenPointToLocalPointInRectangle(CachedRectTransform, eventData.position, mCamera, out p1))
            {
                return;
            }
            if(mIsVertical)
            {
                if(p1.y <= -mMinHeight)
                {
                    CachedRectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, -p1.y);
                }
            }
            else
            {
                if(p1.x >= mMinWidth)
                {
                    CachedRectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, p1.x);
                }
            }
            if (mOnDraggingAction != null)
            {
                mOnDraggingAction();
            }
        }

    }
}
