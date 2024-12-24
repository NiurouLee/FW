using Ez.Core;
using Ez.UI;
using UnityEngine;

namespace Game
{
    public interface IGuide : IRelease
    {
        string GetKey();
        void InitController(IGuideItemRelease manager);
        public GameObject gameObject { get; }
    }
}