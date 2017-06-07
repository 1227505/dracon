function toggleView(drcn, view)
    if(strcmp(drcn.view.(view).fig.Visible, 'on'))
        drcn.view.(view).fig.Visible = 'off';
        drcn.menu.view.(view).Checked = 'off';
    else
        drcn.view.(view).fig.Visible = 'on';
        drcn.menu.view.(view).Checked = 'on';
    end
end