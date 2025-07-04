using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace NFramework.Module.UI.ScrollView
{
    public class RotateScript : MonoBehaviour
    {
        public float speed = 1.0f;

        // Update is called once per frame
        void Update()
        {
            Vector3 rot = gameObject.transform.localEulerAngles;
            rot.z = rot.z + speed * Time.deltaTime;
            gameObject.transform.localEulerAngles = rot;
        }
    }
}
