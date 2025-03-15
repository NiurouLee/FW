
using System;
using System.Collections;
using System.Reflection;
using System.Threading.Tasks;
using Proto.Promises;
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

    



}
