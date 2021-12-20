import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import plotly.express as px
import plotly.io as pio
import json

def sites_map():
    # Map
    state_vn  = pd.read_csv("data/vietnam_state.csv")

    #Vietnam map
    vietnam_geo = json.load(open("data/vietnam_state.geojson","r"))

    # Plotting
    fig = px.choropleth_mapbox(
        state_vn,
        locations = 'Code',
        featureidkey="properties.Code",
        geojson = vietnam_geo,
        color_continuous_scale='Mint',
        color = 'Weight',
        hover_name = "Name",
        # labels ="Name",
        mapbox_style = "carto-positron",
        center = {"lat": 16,"lon": 106},
        zoom = 4.8,
        opacity=0.9,
    )
    fig.update_layout(
        autosize=False,
        width=500,
        height=800,
        showlegend=False
    )
    fig.update_geos(fitbounds = "locations",visible=False )

    fig.show()

def corr_matrix(yc_panel):

    round2=yc_panel[(yc_panel['round']==2)]
    df= round2[['urban','moreable','majorethnic','carehedu','stuntearly','female']]
    df.rename(columns={'majorethnic':'majority','carehedu':'caredu','stuntearly':'early stuntness'},inplace=True)
    
    corr_matrix=df.corr()
    mask = np.zeros_like(corr_matrix)
    mask[np.triu_indices_from(mask)] = True

    sns.set(font_scale = 1.2)
    ax = sns.heatmap(corr_matrix, mask=mask, square=True,cmap="vlag")
    ax.figure.set_size_inches(9, 6)
    ax.set_title('Figure 2.2: Correlation among advantage backgrounds')

def wi_ppvt(x,tit,yc_panel):
    df = yc_panel[yc_panel['round']!=1]

    sns.set(font_scale = 1.5)
    ax= sns.relplot(x="wiquant", y="ppvt_perco",hue=x, kind="line",data=df,col_wrap=2 ,col="round",style=x,dashes=True)
    ax.figure.set_size_inches(9.5, 6.5)
    ax.set(xlabel='Wealth Index Quantiles', ylabel='PPVT Percentile Score')
    sns.move_legend(ax, "lower center",bbox_to_anchor=(.45, 1) ,ncol=2,title=tit, frameon=False)
