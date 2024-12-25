using Ez.Assets;
using Game;
using UnityEngine;

namespace Ez.UI
{
    internal class UIBuildParam
    {
        public string name;

        public PersentingData data;
        public UIControllerBase controller;

        public ResHandle mainResHandle;
        public GroupLoader groupLoader;

        public UIBuilder.OnControllerReady callback;
    }

    internal class UIBuilder
    {
        public delegate void OnControllerReady(string uiname, UIControllerBase controller);

        public static System.Reflection.Assembly assembly;

        /**
         * 注意：有可能回调比同步快，看情况吧，在 Adapter 层，直接缓存回调时，延迟一帧其实更简单些
         */

        public static UIControllerBase BuildUI(PersentingData data, OnControllerReady callback)
        {
            string uiname = data.uiname;

            UIBuildParam buildParam = new UIBuildParam();
            buildParam.data = data;
            buildParam.name = uiname;
            buildParam.callback = callback;

            System.Type ctype = assembly.GetType(buildParam.name);
            if (ctype == null)
            {
                data.isReady = true;
                data.hasError = true;
                callback(uiname, null);
                return null;
            }

            UIControllerBase controller = System.Activator.CreateInstance(ctype) as UIControllerBase;
            controller.SetParam(data.param, data.ctrlparam);

            data.controller = controller;
            buildParam.controller = controller;

            // 预加载部分 TODO@bao
            controller.DoPreloadAssets();
            buildParam.groupLoader = controller.GroupLoader();

            buildParam.mainResHandle = client.AssetUtil.adapter.LoadAssetAsync(controller.GetPrefabKey(), typeof(GameObject));
            buildParam.mainResHandle.SetCallback((resHandle) =>
            {
                if (resHandle.Asset != null)
                {
                    buildParam.controller.InitMainView(resHandle); ;
                }
                else
                {
                    DevDebuger.LogError("UIBuilder", $"current ui {resHandle.AssetKey} is null");
                }
                OnLoadFinished(buildParam);
            });

            buildParam.groupLoader?.Begin(() => { OnLoadFinished(buildParam); });

            return controller;
        }

        private static void OnLoadFinished(UIBuildParam bparam)
        {
            if (!bparam.mainResHandle.isDone)
                return;

            if (bparam.groupLoader != null && !bparam.groupLoader.IsDone)
                return;

            UIDebuger.LogDetail("UIBuilder", $"{bparam.name} OnLoadFinished");

            if (bparam.callback != null)
            {
                UIDebuger.BeginSample("uibuilder callback");

                bparam.data.isReady = true;
                if (bparam.mainResHandle.Asset == null)
                {
                    bparam.data.hasError = true;
                    if (bparam.groupLoader != null) // 出错预加载的也得释放
                    {
                        bparam.groupLoader.Release();
                    }
                }
                bparam.callback(bparam.name, bparam.controller);

                UIDebuger.EndSample();
            }
            else
            {
                DevDebuger.LogError("UIBuilder", "OnLoadFinished param is null");
            }
        }
    }
}