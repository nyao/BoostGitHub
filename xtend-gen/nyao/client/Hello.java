package nyao.client;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.RootPanel;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

@SuppressWarnings("all")
public class Hello implements EntryPoint {
  public void onModuleLoad() {
    Button _button = new Button("click");
    final Button button = _button;
    final Procedure1<ClickEvent> _function = new Procedure1<ClickEvent>() {
        public void apply(final ClickEvent it) {
          RootPanel _get = RootPanel.get("Label");
          Label _label = new Label("hello");
          _get.add(_label);
        }
      };
    button.addClickHandler(new ClickHandler() {
        public void onClick(ClickEvent event) {
          _function.apply(event);
        }
    });
    RootPanel _get = RootPanel.get("Button");
    _get.add(button);
  }
}
