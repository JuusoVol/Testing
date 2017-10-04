*** Settings ***

Library	   			Collections
Library				RequestsLibrary
Library				String
Library				DateTime
Library				Selenium2Library
Resource            ../CommonResource.robot

*** Variables ***
@{BROWSERS}			gc	ie	edge
${BROWSER}       	@{BROWSERS}[0]
${DELAY}         	5
${DEFAULT_TIMEOUT}	15
${LOGIN_URL}

#	Valid Credentials, different customer scenarios
@{credentials_1}     TestRobot  TestRobot1
@{credentials_2}     TestRobot  TestRobot1
@{credentials_3}     TestRobot  TestRobot1

#	Set user
@{chosen_user}  	@{credentials_1}
${USER}				@{chosen_user}[0]
${PASSWORD}			@{chosen_user}[1]


*** Keywords ***

Run on Failure
	[Documentation]	Executed when an error happens during execution
	Log Variables
	Run Keyword And Ignore Error	Capture Page Screenshot	${SUITE NAME}_${TEST NAME}.png
	Log Source

Suite Set Up
	[Documentation]	Setting up the suite settings.
	Log	Starting test

Clean Up Test
	[Documentation]	We clean up respurces when the case ends.
	Delete All Cookies
	Run Keyword And Ignore Error	Capture Page Screenshot
	${previous kw}=	Register Keyword To Run On Failure	Nothing	# Disables run-on-failure functionality and stores the previous kw name in a variable.
	Run Keyword And Ignore Error	Close Browser
	Register Keyword To Run On Failure	${previous kw}	# Restore to the previous keyword.

Clean Up Suite
	[Documentation]	All browsers should be closed when the tests end.
	${previous kw}=	Register Keyword To Run On Failure	Nothing	# Disables run-on-failure functionality and stores the previous kw name in a variable.
	Run Keyword And Ignore Error	Close All Browsers	# Browser closing may result in errors, even tough the browser is closed.
	Register Keyword To Run On Failure	${previous kw}	# Restore to the previous keyword.

#	Generic Navigation and Browser behaviour
Click Element If Not Visible
	[Documentation]	Checks if the given element is present at the page,
	...				if it isn't, clicks the specified element (e.g., a link to the correct page)
	[Arguments]	${expectedElement}	${elementToClick}
	${status}	${value} =	Run Keyword And Ignore Error	Page Should Contain Element	${expectedElement}
	Run Keyword Unless		'${status}' == 'PASS'	Bilot Click Link	${elementToClick}
	Wait Until Page Contains Element	${expectedElement}

Click Element If Visible
	[Documentation]
	[Arguments]	${element}
	${status}	${value} =	Run Keyword And Ignore Error	Page Should Contain Element	${element}
	Run Keyword Unless		'${status}' != 'PASS'	Bilot Click Link	${element}

Go to URL If Not Visible
	[Documentation]	Checks if the given element is present at the page,
	...				if it isn't, goes to the given URL (e.g., a link to the correct page)
	[Arguments]	${expectedElement}	${url}
	${status}	${value} =	Run Keyword And Ignore Error	Page Should Contain Element ${expectedElement}
	Run Keyword Unless		'${status}' == 'PASS'	Go To	${url}
	Wait Until Page Contains Element	${expectedElement}

Do Not Use Directly Check Input Value
	[Documentation]	check input field value
	[Arguments]	${locator}    ${value}
    ${value}=	Get Value	${locator}
    Should Be True	'${val}' == '${expectedValue}'

Check Input Value
	[Arguments]	${locator}    ${value}
	Wait Until Keyword Succeeds	10 s	1 s	Do Not Use Directly Check Input Value	${locator} 	${value}

Check Element Value
	[Arguments]	${locator}    ${value}
	Wait Until Page Contains Element	${locator}
	Wait Until Keyword Succeeds	10 s	1 s	Element Text Should Be	${locator} 	${value}

Bilot Get Element Text
	[Arguments]	${locator}
	[Return]    ${value}
	Wait Until Page Contains Element	${locator}
	${value}=     Wait Until Keyword Succeeds	10 s	1 s		Get Text	${locator}

Bilot Get Element Value
	[Arguments]	${locator}
	[Return]    ${value}
	Wait Until Page Contains Element	${locator}
	${value}=     Wait Until Keyword Succeeds	10 s	1 s		Get Value	${locator}

Set Input Value
	[Documentation]	clears field and sets the value. also waits untill value has been set
	[Arguments]	${locator}    ${value}
	Wait Until Page Contains Element	${locator}
	Input Text	${locator} 	${Empty}
	Check Input Value	${locator} 	${Empty}
	Input Text	${locator} 	${value}
	Check Input Value	${locator} 	${value}

Input Text And Verify Value
    [Documentation]  Inputs text into field, uses Focus and verifies that the value has been set
    [Arguments]  ${locator}    ${value}
    Focus   ${locator}
    Input Text  ${locator}   ${value}
    # Press tab-key to get focus out of the text box
    Press Key    ${locator}   \t
    ${field_value} =    Get Value    ${locator}
    Should Match  ${field_value}   ${value}

Robust Click Link
	[Arguments]	${locator}
	Wait Until Page Contains Element	${locator}
	Wait Until Keyword Succeeds	15 s	1 s     Click Element	${locator}

Robust Mouse Over
	[Arguments]	${locator}
	Wait Until Page Contains Element	${locator}
	Sleep   1
	Wait Until Keyword Succeeds	15 s	1 s     Mouse Over	${locator}

Element Attribute Should Be
	[Arguments]	${locator}    ${value}
    ${temp}=      Get Element Attribute     ${locator}
    Should Be Equal As Strings  ${temp}     ${value}

Element Text Should Be
	[Arguments]	${locator}    ${value}
    ${temp}=    Bilot Get Element Text     ${locator}
    Should Be Equal As Strings  ${temp}     ${value}

Get Field Length
    [Arguments]    ${locator}
    [Documentation]  This keyword reads the field length and stores it in variable
    ${character_count} =  Get Length     ${locator}

Clear Field Of Characters
    [Arguments]    ${locator}   ${value}
    [Documentation]    This keyword pushes the delete key (ascii: \8) a specified number of times in a specified field.
    :FOR    ${index}    IN RANGE    ${value}
    \    Press Key    ${locator}    \\8