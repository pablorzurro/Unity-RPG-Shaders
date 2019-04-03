﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AbilityButtonManager : MonoBehaviour
{
    [SerializeField]
    float m_loadingTime;

    [SerializeField]
    float m_enchantmentDuration;

    [SerializeField]
    Image m_abilityButtonImage;

    Material m_abilityButtonMaterialInstance;

    float m_elapsedTime;


    bool m_isButtonClicked;
    bool m_isLoading;

    bool m_enchantmentFinished;
    bool m_loadingFinished;

    // Start is called before the first frame update
    void Start()
    {
        if(m_loadingTime != null)
        {
            m_abilityButtonMaterialInstance = m_abilityButtonImage.material;
        }

        m_isButtonClicked = false;
        m_loadingFinished = true;

        m_elapsedTime = 0.0f;

        StartEnchantmentEffect();
    }

    // Update is called once per frame
    void Update()
    {
        if(m_isButtonClicked)
        {
            m_isButtonClicked = false;

            StartLoading();
        }

        if(m_isLoading)
        {
            m_elapsedTime += Time.deltaTime;

            float currentLoadingValue = m_elapsedTime / m_loadingTime; // Percentage between two values (0.0 - m_loadingTime)
            m_abilityButtonMaterialInstance.SetFloat("_LoadingValue", currentLoadingValue);
        }
    }

    public void GetButtonClick()
    {
        m_isButtonClicked = true;
    }

    void StartLoading()
    {
        m_loadingFinished = false;
        FinishEnchantmentEffect(); // Finish it if is already running
        m_elapsedTime = 0.0f;
        m_isLoading = true;
        Invoke("FinishLoading", m_loadingTime);
    }

    void FinishLoading()
    {
        m_isLoading = false;
   
        StartEnchantmentEffect();
    }

    void StartEnchantmentEffect()
    {
        m_enchantmentFinished = false;
        m_abilityButtonMaterialInstance.SetFloat("_IsEnchanted", 1.0f);
        m_abilityButtonMaterialInstance.SetFloat("_LoadingValue", 1.0f);
    }

    void FinishEnchantmentEffect()
    {
        if(!m_enchantmentFinished)
        {
            m_abilityButtonMaterialInstance.SetFloat("_IsEnchanted", 0.0f);
        }

        m_enchantmentFinished = true;
    }
}