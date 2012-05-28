package nyao.client

import com.google.gwt.core.client.EntryPoint
import com.google.gwt.user.client.ui.RootPanel
import com.google.gwt.user.client.ui.Button
import com.google.gwt.user.client.ui.Label

class Hello implements EntryPoint {
	override onModuleLoad() {
		val button = new Button("click")
		button.addClickHandler([RootPanel::get("Label").add(new Label("hello"))])
		RootPanel::get("Button").add(button)
	}
}
