using System;
using NFramework.Event;
using UnityEngine;

namespace NFramework.Test.EventTestEx
{
    public class EventTestMono : MonoBehaviour
    {
        private void Start()
        {
            var register = new RegisterEx();
            register.TestRegister();
            register.TestRegisterChannel();
            register.TestRegisterFilter();

            var fire = new FireEx();
            fire.FireNormal();
            fire.FireChannel();

            register.LogCount();

            register.TestUnRegister();
            register.TestUnRegisterChannel();
            register.TestUnRegisterFilter();
        }
    }
}