using UnityEngine;

namespace Ez.UI
{
    [RequireComponent(typeof(Canvas))]
    [RequireComponent(typeof(UnityEngine.UI.RawImage))]
    public class UIBlurLayer : MonoBehaviour
    {
        private UnityEngine.UI.RawImage _rawImage;

        void Awake()
        {
            if (_rawImage == null) _rawImage = GetComponent<UnityEngine.UI.RawImage>();
            _rawImage.enabled = false;
        }

        public void SetRawTexture(Texture rt)
        {
            if (rt == null)
            {
                Debug.LogError("rt is null");
                return;
            }
            _rawImage.texture = rt;
            _rawImage.enabled = true;
        }

        void OnDestroy()
        {
            _rawImage.enabled = false;
        }
    }
}
