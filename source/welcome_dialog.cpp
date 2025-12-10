//////////////////////////////////////////////////////////////////////
// This file is part of Remere's Map Editor
//////////////////////////////////////////////////////////////////////
// Remere's Map Editor is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Remere's Map Editor is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//////////////////////////////////////////////////////////////////////

#include "main.h"
#include "welcome_dialog.h"
#include "settings.h"
#include "preferences.h"

wxDEFINE_EVENT(WELCOME_DIALOG_ACTION, wxCommandEvent);

// Helper function to get theme colors based on icon background setting
static WelcomeDialogTheme GetThemeColors() {
	WelcomeDialogTheme theme;
	int icon_bg = g_settings.getInteger(Config::ICON_BACKGROUND);

	if (icon_bg == 0) {
		// Dark theme (black background)
		theme.base_colour = wxColour(45, 45, 48);
		theme.text_colour = wxColour(220, 220, 220);
		theme.secondary_text_colour = wxColour(160, 160, 160);
		theme.button_colour = wxColour(60, 60, 65);
		theme.button_hover_colour = wxColour(70, 70, 75);
		theme.recent_panel_colour = wxColour(37, 37, 40);
		theme.checkbox_text_colour = wxColour(220, 220, 220);
	} else if (icon_bg == 88) {
		// Gray theme
		theme.base_colour = wxColour(180, 180, 180);
		theme.text_colour = wxColour(40, 40, 40);
		theme.secondary_text_colour = wxColour(80, 80, 80);
		theme.button_colour = wxColour(160, 160, 165);
		theme.button_hover_colour = wxColour(140, 140, 145);
		theme.recent_panel_colour = wxColour(195, 195, 195);
		theme.checkbox_text_colour = wxColour(40, 40, 40);
	} else {
		// Light theme (white background = 255 or default)
		theme.base_colour = wxColour(250, 250, 250);
		theme.text_colour = theme.base_colour.ChangeLightness(40);
		theme.secondary_text_colour = theme.base_colour.ChangeLightness(110);
		theme.button_colour = theme.base_colour.ChangeLightness(96);
		theme.button_hover_colour = theme.base_colour.ChangeLightness(93);
		theme.recent_panel_colour = theme.base_colour.ChangeLightness(98);
		theme.checkbox_text_colour = wxColour(51, 51, 51);
	}

	return theme;
}

WelcomeDialog::WelcomeDialog(const wxString &title_text, const wxString &version_text, const wxSize &size, const wxBitmap &rme_logo, const std::vector<wxString> &recent_files) :
	wxDialog(nullptr, wxID_ANY, "", wxDefaultPosition, size) {
	Centre();
	WelcomeDialogTheme theme = GetThemeColors();
	m_welcome_dialog_panel = newd WelcomeDialogPanel(this, GetClientSize(), title_text, version_text, theme, recent_files);
}

void WelcomeDialog::OnButtonClicked(const wxMouseEvent &event) {
	auto* button = dynamic_cast<WelcomeDialogButton*>(event.GetEventObject());
	wxSize button_size = button->GetSize();
	wxPoint click_point = event.GetPosition();
	if (click_point.x > 0 && click_point.x < button_size.x && click_point.y > 0 && click_point.y < button_size.x) {
		if (button->GetAction() == wxID_PREFERENCES) {
			PreferencesWindow preferences_window(m_welcome_dialog_panel);
			preferences_window.ShowModal();
			m_welcome_dialog_panel->updateInputs();
		} else {
			wxCommandEvent action_event(WELCOME_DIALOG_ACTION);
			if (button->GetAction() == wxID_OPEN) {
				wxString wildcard = "OpenTibia Binary Map (*.otbm)|*.otbm";
				wxFileDialog file_dialog(this, "Open map file", "", "", wildcard, wxFD_OPEN | wxFD_FILE_MUST_EXIST);
				if (file_dialog.ShowModal() == wxID_OK) {
					action_event.SetString(file_dialog.GetPath());
				} else {
					return;
				}
			}
			action_event.SetId(button->GetAction());
			ProcessWindowEvent(action_event);
		}
	}
}

void WelcomeDialog::OnCheckboxClicked(const wxCommandEvent &event) {
	g_settings.setInteger(Config::WELCOME_DIALOG, event.GetInt());
}

void WelcomeDialog::OnRecentItemClicked(const wxMouseEvent &event) {
	auto* recent_item = dynamic_cast<RecentItem*>(event.GetEventObject());
	wxSize button_size = recent_item->GetSize();
	wxPoint click_point = event.GetPosition();
	if (click_point.x > 0 && click_point.x < button_size.x && click_point.y > 0 && click_point.y < button_size.x) {
		wxCommandEvent action_event(WELCOME_DIALOG_ACTION);
		action_event.SetString(recent_item->GetText());
		action_event.SetId(wxID_OPEN);
		ProcessWindowEvent(action_event);
	}
}

WelcomeDialogPanel::WelcomeDialogPanel(WelcomeDialog* dialog, const wxSize &size, const wxString &title_text, const wxString &version_text, const WelcomeDialogTheme &theme, const std::vector<wxString> &recent_files) :
	wxPanel(dialog),
	m_title_text(title_text),
	m_version_text(version_text),
	m_text_colour(theme.text_colour),
	m_background_colour(theme.base_colour) {

	auto* recent_maps_panel = newd RecentMapsPanel(this, dialog, theme, recent_files);
	recent_maps_panel->SetMaxSize(wxSize(size.x / 2, size.y));
	recent_maps_panel->SetBackgroundColour(theme.recent_panel_colour);

	// Create title label
	m_title_label = newd wxStaticText(this, wxID_ANY, title_text);
	wxFont title_font = GetFont();
	title_font.SetPointSize(18);
	m_title_label->SetFont(title_font);
	m_title_label->SetForegroundColour(theme.text_colour);

	// Create version label
	m_version_label = newd wxStaticText(this, wxID_ANY, version_text);
	m_version_label->SetFont(GetFont());
	m_version_label->SetForegroundColour(theme.secondary_text_colour);

	wxSize button_size = FROM_DIP(this, wxSize(150, 35));

	auto* new_map_button = newd WelcomeDialogButton(this, wxDefaultPosition, button_size, theme.button_colour, theme.button_hover_colour, theme.text_colour, "New");
	new_map_button->SetAction(wxID_NEW);
	new_map_button->Bind(wxEVT_LEFT_UP, &WelcomeDialog::OnButtonClicked, dialog);

	auto* open_map_button = newd WelcomeDialogButton(this, wxDefaultPosition, button_size, theme.button_colour, theme.button_hover_colour, theme.text_colour, "Open");
	open_map_button->SetAction(wxID_OPEN);
	open_map_button->Bind(wxEVT_LEFT_UP, &WelcomeDialog::OnButtonClicked, dialog);
	auto* preferences_button = newd WelcomeDialogButton(this, wxDefaultPosition, button_size, theme.button_colour, theme.button_hover_colour, theme.text_colour, "Preferences");
	preferences_button->SetAction(wxID_PREFERENCES);
	preferences_button->Bind(wxEVT_LEFT_UP, &WelcomeDialog::OnButtonClicked, dialog);

	Bind(wxEVT_PAINT, &WelcomeDialogPanel::OnPaint, this);

	// Create checkbox
	m_show_welcome_dialog_checkbox = newd wxCheckBox(this, wxID_ANY, "Show this dialog on startup");
	m_show_welcome_dialog_checkbox->SetValue(g_settings.getInteger(Config::WELCOME_DIALOG) == 1);
	m_show_welcome_dialog_checkbox->Bind(wxEVT_CHECKBOX, &WelcomeDialog::OnCheckboxClicked, dialog);
	m_show_welcome_dialog_checkbox->SetBackgroundColour(theme.base_colour);
	m_show_welcome_dialog_checkbox->SetForegroundColour(theme.checkbox_text_colour);

	// Create main horizontal layout (two columns)
	wxSizer* rootSizer = newd wxBoxSizer(wxHORIZONTAL);

	// Left column
	wxSizer* left_column_sizer = newd wxBoxSizer(wxVERTICAL);

	// Add title section with proper spacing
	left_column_sizer->AddSpacer(FROM_DIP(this, 40));
	left_column_sizer->Add(m_title_label, 0, wxALIGN_CENTER);
	left_column_sizer->Add(m_version_label, 0, wxALIGN_CENTER | wxTOP, FROM_DIP(this, 10));

	// Add flexible space before buttons
	left_column_sizer->AddStretchSpacer(1);

	// Add buttons
	wxSizer* buttons_sizer = newd wxBoxSizer(wxVERTICAL);
	buttons_sizer->Add(new_map_button, 0, wxALIGN_CENTER | wxTOP, FROM_DIP(this, 10));
	buttons_sizer->Add(open_map_button, 0, wxALIGN_CENTER | wxTOP, FROM_DIP(this, 10));
	buttons_sizer->Add(preferences_button, 0, wxALIGN_CENTER | wxTOP, FROM_DIP(this, 10));
	left_column_sizer->Add(buttons_sizer, 0, wxALIGN_CENTER);

	// Add flexible space before checkbox
	left_column_sizer->AddStretchSpacer(1);

	// Add checkbox at bottom
	wxSizer* checkbox_sizer = newd wxBoxSizer(wxHORIZONTAL);
	checkbox_sizer->Add(m_show_welcome_dialog_checkbox, 0, wxALIGN_BOTTOM | wxALL, FROM_DIP(this, 10));
	left_column_sizer->Add(checkbox_sizer, 0, wxEXPAND);

	// Add both columns to root
	rootSizer->Add(left_column_sizer, 1, wxEXPAND);
	rootSizer->Add(recent_maps_panel, 1, wxEXPAND);
	SetSizer(rootSizer);
}

void WelcomeDialogPanel::updateInputs() {
	m_show_welcome_dialog_checkbox->SetValue(g_settings.getInteger(Config::WELCOME_DIALOG) == 1);
}

void WelcomeDialogPanel::OnPaint(const wxPaintEvent &event) {
	wxPaintDC dc(this);

	dc.SetBrush(wxBrush(m_background_colour));
	dc.SetPen(wxPen(m_background_colour));
	dc.DrawRectangle(wxRect(wxPoint(0, 0), GetClientSize()));
}

WelcomeDialogButton::WelcomeDialogButton(wxWindow* parent, const wxPoint &pos, const wxSize &size, const wxColour &button_colour, const wxColour &button_hover_colour, const wxColour &text_colour, const wxString &text) :
	wxPanel(parent, wxID_ANY, pos, size),
	m_action(wxID_CLOSE),
	m_text(text),
	m_text_colour(text_colour),
	m_background(button_colour),
	m_background_hover(button_hover_colour),
	m_is_hover(false) {
	Bind(wxEVT_PAINT, &WelcomeDialogButton::OnPaint, this);
	Bind(wxEVT_ENTER_WINDOW, &WelcomeDialogButton::OnMouseEnter, this);
	Bind(wxEVT_LEAVE_WINDOW, &WelcomeDialogButton::OnMouseLeave, this);
}

void WelcomeDialogButton::OnPaint(const wxPaintEvent &event) {
	wxPaintDC dc(this);

	wxColour colour = m_is_hover ? m_background_hover : m_background;
	dc.SetBrush(wxBrush(colour));
	dc.SetPen(wxPen(colour, 1));
	dc.DrawRectangle(wxRect(wxPoint(0, 0), GetClientSize()));

	dc.SetFont(GetFont());
	dc.SetTextForeground(m_text_colour);
	wxSize text_size = dc.GetTextExtent(m_text);
	dc.DrawText(m_text, wxPoint(GetSize().x / 2 - text_size.x / 2, GetSize().y / 2 - text_size.y / 2));
}

void WelcomeDialogButton::OnMouseEnter(const wxMouseEvent &event) {
	m_is_hover = true;
	Refresh();
}

void WelcomeDialogButton::OnMouseLeave(const wxMouseEvent &event) {
	m_is_hover = false;
	Refresh();
}

RecentMapsPanel::RecentMapsPanel(wxWindow* parent, WelcomeDialog* dialog, const WelcomeDialogTheme &theme, const std::vector<wxString> &recent_files) :
	wxPanel(parent, wxID_ANY) {
	wxBoxSizer* sizer = new wxBoxSizer(wxVERTICAL);
	for (const wxString &file : recent_files) {
		auto* recent_item = newd RecentItem(this, theme, file);
		sizer->Add(recent_item, 0, wxEXPAND);
		recent_item->Bind(wxEVT_LEFT_UP, &WelcomeDialog::OnRecentItemClicked, dialog);
	}
	SetSizerAndFit(sizer);
}

RecentItem::RecentItem(wxWindow* parent, const WelcomeDialogTheme &theme, const wxString &item_name) :
	wxPanel(parent, wxID_ANY),
	m_text_colour(theme.text_colour),
	m_text_colour_hover(theme.secondary_text_colour),
	m_item_text(item_name) {
	SetBackgroundColour(theme.button_colour);
	m_title = newd wxStaticText(this, wxID_ANY, wxFileNameFromPath(m_item_text));
	m_title->SetFont(GetFont().Bold());
	m_title->SetForegroundColour(m_text_colour);
	m_title->SetToolTip(m_item_text);
	m_file_path = newd wxStaticText(this, wxID_ANY, m_item_text, wxDefaultPosition, wxDefaultSize, wxST_ELLIPSIZE_START);
	m_file_path->SetToolTip(m_item_text);
	m_file_path->SetFont(GetFont().Smaller());
	m_file_path->SetForegroundColour(m_text_colour);
	wxBoxSizer* mainSizer = newd wxBoxSizer(wxHORIZONTAL);
	wxBoxSizer* sizer = newd wxBoxSizer(wxVERTICAL);
	sizer->Add(m_title);
	sizer->Add(m_file_path, 1, wxTOP, FROM_DIP(this, 2));
	mainSizer->Add(sizer, 0, wxEXPAND | wxALL, FROM_DIP(this, 8));
	Bind(wxEVT_ENTER_WINDOW, &RecentItem::OnMouseEnter, this);
	Bind(wxEVT_LEAVE_WINDOW, &RecentItem::OnMouseLeave, this);
	m_title->Bind(wxEVT_LEFT_UP, &RecentItem::PropagateItemClicked, this);
	m_file_path->Bind(wxEVT_LEFT_UP, &RecentItem::PropagateItemClicked, this);
	SetSizerAndFit(mainSizer);
}

void RecentItem::PropagateItemClicked(wxMouseEvent &event) {
	event.ResumePropagation(1);
	event.SetEventObject(this);
	event.Skip();
}

void RecentItem::OnMouseEnter(const wxMouseEvent &event) {
	if (GetScreenRect().Contains(ClientToScreen(event.GetPosition()))
		&& m_title->GetForegroundColour() != m_text_colour_hover) {
		m_title->SetForegroundColour(m_text_colour_hover);
		m_file_path->SetForegroundColour(m_text_colour_hover);
		m_title->Refresh();
		m_file_path->Refresh();
	}
}

void RecentItem::OnMouseLeave(const wxMouseEvent &event) {
	if (!GetScreenRect().Contains(ClientToScreen(event.GetPosition()))
		&& m_title->GetForegroundColour() != m_text_colour) {
		m_title->SetForegroundColour(m_text_colour);
		m_file_path->SetForegroundColour(m_text_colour);
		m_title->Refresh();
		m_file_path->Refresh();
	}
}
