# SPDX-License-Identifier: Apache-2.0

"""
The classes below are examples of user-defined CommitRules. Commit rules are gitlint rules that
act on the entire commit at once. Once the rules are discovered, gitlint will automatically take care of applying them
to the entire commit. This happens exactly once per commit.

A CommitRule contrasts with a LineRule (see examples/my_line_rules.py) in that a commit rule is only applied once on
an entire commit. This allows commit rules to implement more complex checks that span multiple lines and/or checks
that should only be done once per gitlint run.

While every LineRule can be implemented as a CommitRule, it's usually easier and more concise to go with a LineRule if
that fits your needs.

For specific details, please refer to: https://jorisroovers.com/gitlint/0.19.x/rules/
"""

from typing import List
from gitlint.rules import CommitRule, RuleViolation, CommitMessageTitle, LineRule, CommitMessageBody
from gitlint.options import IntOption, StrOption
import re

openeuler_footers = ['Signed-off-by', 'Closes', 'Fixes', 'Co-developed-by', 'Link']

def divide_body_and_footer(body: List[str]):
    '''
    In gitlint, commit msg consist of title and body.
    But In openEuler embedded, commit msg consist of title, body and footer.
    Correspondingly,  body add footer in openEuler embedded is equal to the body in gitlint.
    '''
    if len(body) == 0:
        return ([], [])
    
    flags = re.UNICODE
    flags |= re.IGNORECASE
    #value of -1 indicates that there are no tags matching in the openeuler_footers
    first_footer_index = -1
    for body_line_num, body_line in enumerate(body):
        if len(body_line.strip()) == 0:
            continue
        #loop matching to determine if it is defined as tag in openeuler_footers
        #find the index of the first tag to divide body and footer in openEuler embedded
        is_match = False
        for openeuler_footer in openeuler_footers:
            pattern = "(^)" + openeuler_footer + ":(.*)"
            if re.search(pattern, body_line, flags=flags):
                is_match = True
                if first_footer_index == -1:
                    first_footer_index = body_line_num
                break
        if not is_match:
            first_footer_index = -1
    #return to the body list and footer list
    if first_footer_index != -1:
        real_body = body[:first_footer_index]
        #use len(body)-1 because the last line in body is always blankline
        if len(body[-1].strip()) == 0:
            real_footer = body[first_footer_index:len(body)-1]
        else:
            real_footer = body[first_footer_index:len(body)]
    else:
        real_body = body
        real_footer = []
    return (real_body, real_footer)

class BlanklineBetweenThreePartsCheck(CommitRule):
    '''
    Commit Massage consists of three parts:header, body and footer.
    There must be one blank line between header and body, and between body and footer
    '''
    name = "blankline-between-three-parts-check"
    id = "UC1"
    message = "There must be one blankline between header and body, and between body and footer"

    def validate(self, commit):
        result = []
        real_body, real_footer = divide_body_and_footer(commit.message.body)
        is_body_have_words = False
        for line in real_body:
            if len(line.strip()) > 0:
                is_body_have_words = True
        is_footer_have_words = False
        for line in real_footer:
            if len(line.strip()) > 0:
                is_footer_have_words = True
        if is_body_have_words:
            if len(real_body[0].strip()) != 0:
                result.append(RuleViolation(self.id, "There must be one blankline between header and body", real_body[0], 2))
        if is_body_have_words and is_footer_have_words:
            if len(real_body[-1].strip()) != 0:
                result.append(RuleViolation(self.id, "There must be one blankline between body and footer", real_footer[0], len(real_body) + 1))
        return result

class TitleLength(LineRule):
    '''
    The maximum length of the title should not exceed 80 characters when not revert.
    The maximum length of the title should not exceed 102 characters when revert.
    Subject contains at least 2 words.
    '''
    name = "title-length"
    id = "UT1"
    target = CommitMessageTitle
    options_spec = [IntOption('line-max-length-no-revert', 80, "Max line length when no revert"),
                    IntOption('line-max-length-revert', 102, "Max line length when revert")]
    message = "Title exceeds max length ({0}>{1})"

    def validate(self, line, _commit):
        result = []
        if line.startswith("revert"):
            max_length = self.options['line-max-length-revert'].value
        else:
            max_length = self.options['line-max-length-no-revert'].value
            self.message = "Title exceeds max length ({0}>{1}) when revert"
        if len(line) > max_length:
            result.append(RuleViolation(self.id, self.message.format(len(line), max_length), line))

        #The subject contains at least 3 words.
        if line.find(": ") != -1:
            subject = line[line.find(": ") + 2 : ].strip()
            if len(subject) != 0 and len(subject.split()) < 2:
                result.append(RuleViolation(self.id, "Subject contains at least 2 words.", line))
        return result

class TitleForm(LineRule):
    '''
    Title form is <area>: <subject>
    area and subject must not be empty
    There is only one space after the colon
    '''
    name = "title-form"
    id = "UT2"
    target = CommitMessageTitle
    message = "The form of title is <area>: <subject>."

    def validate(self, line, _commit):
        result = []
        if line.find(":") == -1:
            result.append(RuleViolation(self.id, self.message, line))
        area = line[0:(line.find(":"))]
        subject = line[(line.find(":")+1):]
        if len(area.strip()) == 0:
            result.append(RuleViolation(self.id, self.message + "<area> must not be empty", line))
        if len(subject.strip()) == 0:
            result.append(RuleViolation(self.id, self.message + "<subject> must not be empty", line))
        else:
            if subject[0] != ' ' or (subject[0] == ' ' and subject[1] == ' '):
                result.append(RuleViolation(self.id, self.message + "There is only one space after the colon", line))
            #if subject.strip()[0].islower() and not area.startswith("revert"):
            #    result.append(RuleViolation(self.id, "The first letter of subject must be capitalized", line))
            if not re.match('.*[^?:!.,;]$', subject.strip()) :
                result.append(RuleViolation(self.id, "Title has trailing punctuation", line))
            if area.startswith("revert"):
                if not re.search(r'[a-z0-9]{12}\(\S.*(:\s)[A-Za-z0-9]+.*[^?:!.,;]\)$', subject.strip()):
                    message = '''The from of title in revert commit is ====> revert: A(B)||A is the first 12 characters of SHA-1 in the fixed commit||B is the title in the fixed commit.'''
                    result.append(RuleViolation(self.id, message, line))
        return result

class BodyOrFooterLineLength(CommitRule):
    '''
    Each line of body and footer cannot exceed 100 characters unless it contains a URL link.
    '''
    name = "body-or-footer-line-length"
    id = "UB1"
    options_spec = [IntOption('max-line-length-no-url-in-body', 100, "Max line length"),
                    IntOption('max-line-length-no-url-in-footer', 100, "Max line length")]
    message = "Line exceeds max length ({0}>{1})"

    def validate(self, commit):
        result = []
        body_max_length = self.options['max-line-length-no-url-in-body'].value
        footer_max_length = self.options['max-line-length-no-url-in-footer'].value
        real_body, real_footer = divide_body_and_footer(commit.message.body)
        line_count = 1
        for line in real_body:
            line_count = line_count + 1
            if re.findall(r'(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]', line):
                continue
            if len(line) > body_max_length:
                result.append(RuleViolation(self.id, self.message.format(len(line), body_max_length), line, line_count))
        line_count = 1 + len(real_body)
        for line in real_footer:
            line_count = line_count + 1
            if re.findall(r'(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]', line):
                continue
            if len(line) > footer_max_length and not line.lower().startswith("Fixes:".lower()):
                result.append(RuleViolation(self.id, self.message.format(len(line), footer_max_length), line, line_count))
            if line.lower().startswith("Fixes:".lower()) and len(line) > 101:
                result.append(RuleViolation(self.id, self.message.format(len(line), 101), line, line_count))
        return result

class BodyAndFooterMissingException(CommitRule):
    '''
    Body and footer must not be empty
    '''
    name = "body-and-footer-missing-exception"
    id = "UB2"

    def validate(self, commit):
        result = []
        real_body, real_footer = divide_body_and_footer(commit.message.body)
        body_is_missing = True
        for line in real_body:
            if len(line.strip()) > 0:
                body_is_missing = False
        if body_is_missing:
            result.append(RuleViolation(self.id, "Body is missing"))
        footer_is_missing = True
        for line in real_footer:
            if len(line.strip()) > 0:
                footer_is_missing = False
        if footer_is_missing:
            result.append(RuleViolation(self.id, "Footer is missing"))
        return result

class BodyAndFooterMaxLineCount(CommitRule):
    '''
    The number of line for body don't exceed 100 
    The number of line for footer don't exceed 20
    '''
    name = "body-and-footer-max-line-count"
    id = "UB3"
    options_spec = [IntOption('max-line-count-in-body', 100, "Maximum body line count"),
                    IntOption('max-line-count-in-footer', 20, "Maximum footer line count")]

    def validate(self, commit):
        result = []
        real_body, real_footer = divide_body_and_footer(commit.message.body)
        body_line_count = len(real_body)
        body_max_line_count = self.options['max-line-count-in-body'].value
        if body_line_count > body_max_line_count:
            message = "Body contains too many lines ({0} > {1})"
            result.append(RuleViolation(self.id, message.format(body_line_count, body_max_line_count)))
        footer_line_count = len(real_footer)
        footer_max_line_count = self.options['max-line-count-in-footer'].value
        if footer_line_count > footer_max_line_count:
            message = "Footer contains too many lines ({0} > {1})"
            result.append(RuleViolation(self.id, message.format(footer_line_count, footer_max_line_count)))
        return result

class TagsCheck(CommitRule):
    '''
    check tags in footer:
    '''
    name = "tags-check"
    id = "UF1"

    def validate(self, commit):
        result = []
        real_body, real_footer = divide_body_and_footer(commit.message.body)
        co_developed_by_index = []
        signed_off_by_index = []
        line_count = 1 + len(real_body)
        for index, line in enumerate(real_footer):
            line_count = line_count + 1

            #1.can't contain blankline
            if len(line.strip()) == 0:
                result.append(RuleViolation(self.id, "The footer can't contain blankline", line, line_count))
                continue

            for openeuler_footer in openeuler_footers:
                #2.match the capitalization of tags
                if line.lower().startswith(openeuler_footer.lower()) and not line.startswith(openeuler_footer):
                    message = "Incorrect capitalization of tag '" + openeuler_footer + "' ,Please pay attention to capitalization."
                    result.append(RuleViolation(self.id, message, line, line_count))

            #3.tag-context can't be empty, and there is a space after the colon
            if (len(line[(line.find(":")+1):].strip()) == 0) or (len(line[(line.find(":")+1):].strip()) != 0 and line[(line.find(":")+1):][0] != ' '):
                message = "The form of footer is '<tag-name>: <tag-context>', tag-context can't be empty. There is a space after the colon"
                result.append(RuleViolation(self.id, message, line, line_count))

            if line.lower().startswith("Co-developed-by".lower()):
                co_developed_by_index.append(index)
                #4.Co-developed-by tag must be followed by a Signed-off-by tag
                if not ((len(real_footer) - 1) >= (index + 1) and real_footer[index + 1].lower().startswith("Signed-off-by".lower())):
                    message = "Co-developed-by tag must be followed by a Signed-off-by tag, and the corresponding person information should be consistent."
                    result.append(RuleViolation(self.id, message, line, line_count))

            #5.check form of tag-context in Signed-off-by tag
            if line.lower().startswith("Signed-off-by".lower()):
                signed_off_by_index.append(index)
                if not re.search(r'(\S+)(\s<)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.>', line[(line.find(":")+1):].strip()):
                    message = "The from of Signed-off-by tag is: Signed-off-by: contributor-name <contributor-email>. Please pay attention to the spaces"
                    result.append(RuleViolation(self.id, message, line, line_count))
            
            #6.check form of tag-context in Fixes tag
            if line.lower().startswith("Fixes".lower()):
                if not re.search(r'[a-z0-9]{12}\(\S.*(:\s)[A-Z]+.*[^?:!.,;]\)$', line[(line.find(":")+1):].strip()):
                    message = "The from of Fixes tag is Fixes: A(B) .A is the first 12 characters of SHA-1 in the fixed commit, B is the title in the fixed commit."
                    result.append(RuleViolation(self.id, message, line, line_count))

        #7.Check the quantity of tag Signed-off-by and whether the last line is Signed-off-by
        if len(signed_off_by_index) == 0 or ((len(signed_off_by_index) != 0) and (signed_off_by_index[-1] != len(real_footer) - 1)):
            message = "There must be Signed-off-by tag in footer, and the last tag of footer must be Signed-off-by tag."
            result.append(RuleViolation(self.id, message))
        elif len(signed_off_by_index) - 1 > len(co_developed_by_index):
            message = "There is some extra Signed-off-by tags in the footer"
            result.append(RuleViolation(self.id, message))
        return result

class LinkInClosesCheck(CommitRule):
    '''
    Match the prefix of URLs in Closes tag which represents issues
    Turn off this check by setting option: prefix-for-closes-tag="disabled"
    '''
    name = 'link-in-footer-check'
    id = 'UF2'
    options_spec = [StrOption('prefix-for-closes-tag', "https://gitee.com/openeuler/", "The prefix of URLs.")]

    def validate(self, commit):
        real_body, real_footer = divide_body_and_footer(commit.message.body)
        prefix = self.options['prefix-for-closes-tag'].value
        if prefix == 'disabled':
            return
        for line in real_footer:
            if line.lower().startswith("Closes".lower()) and not re.search(prefix + ".*", line[(line.find(":")+1):].strip()):
                return [RuleViolation(self.id, "Issue Link in Closes tag don't match prefix:" + prefix, line)]
