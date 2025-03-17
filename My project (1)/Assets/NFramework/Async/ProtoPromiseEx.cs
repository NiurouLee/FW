
using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Threading.Tasks;
using Proto.Promises;
using Proto.Promises.Threading;
using UnityEngine;
using UnityEngine.Networking;
public class ProtoPromiseEx
{

    /// <summary>
    /// unity webRequest 转ProtoPromise
    /// </summary>
    /// <param name="inUrl"></param>
    /// <returns></returns>
    public static async Promise<Texture2D> DownLoadTexture(string inUrl)
    {
        using (var www = UnityWebRequestTexture.GetTexture(inUrl))
        {
            await PromiseYielder.WaitFor(www.SendWebRequest());
            if (www.result != UnityWebRequest.Result.Success)
            {
                throw Promise.RejectException(www.error);
            }
            return ((DownloadHandlerTexture)www.downloadHandler).texture;
        }
    }


    /// <summary>
    /// 使用 协程加载texture 并制作成Sprite
    /// </summary>
    /// <param name="inUrl"></param>
    /// <returns></returns>
    IEnumerator GetAndAssignTexture(string inUrl)
    {
        using (var textureYieldInstruction = DownLoadTexture(inUrl).ToYieldInstruction())
        {
            yield return textureYieldInstruction;
            var texture = textureYieldInstruction.GetResult();
            var sprite = Sprite.Create(texture, new Rect(0, 0, texture.width, texture.height), new Vector2(0.5f, 0.5f));
            //doing something
        }
    }

    #region  异步锁
    private readonly AsyncLock _mutex = new AsyncLock();
    public async Promise DoStuffAsync()
    {
        using (await _mutex.LockAsync())
        {
            await Task.Delay(TimeSpan.FromSeconds(1));
        }
    }

    #endregion

    


}
