using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KnightColorChanger : MonoBehaviour
{
    [SerializeField]
    Color m_colorRed, m_colorGreen, m_colorBlue, m_colorOrange;

    [SerializeField]
    Renderer m_knightRenderer;

    public void SetColor(string sColor)
    {
        Color color = Color.white;

        switch(sColor)
        {
            case "r":
                color = m_colorRed;
                break;
            case "g":
                color = m_colorGreen;
                break;
            case "b":
                color = m_colorBlue;
                break;
            case "o":
                color = m_colorOrange;
                break;
        }

        m_knightRenderer.material.SetColor("_ReplaceColor", color);
    }
}
